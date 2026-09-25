# == Schema Information
#
# Table name: sell_orders
# Database name: primary
#
#  id            :bigint           not null, primary key
#  cash_change   :integer
#  cash_pay      :integer
#  payment_type  :string
#  status        :string           not null
#  total         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  allocation_id :bigint           not null
#
# Indexes
#
#  index_sell_orders_on_allocation_id  (allocation_id)
#
# Foreign Keys
#
#  fk_rails_...  (allocation_id => allocations.id)
#
class SellOrder < ApplicationRecord
  include AASM

  aasm column: "status" do
    state :opened, initial: true
    state :packed, :invoicing, :delivering, :closed

    event :pack do
      transitions from: :opened, to: :packed
    end

    event :invoice do
      after do
        create_bill
      end
      transitions from: %i[ opened packed delivering ], to: :invoicing, guard: :suborders_are_done?
    end

    event :deliver do
      transitions from: %i[ packed invoicing ], to: :delivering, guard: :delivery_allocation?
    end

    event :close do
      after do
        complete_orders
        create_bill
      end
      transitions from: %i[ delivering invoicing], to: :closed, guard: :is_paid?
    end
  end

  belongs_to :allocation
  has_many :orders, dependent: :destroy
  has_one :bill

  enum :payment_type, { cash: "cash", transfer: "transfer", card: "card" }

  validates :status, presence: true
  validates :total, numericality: { greater_than: 0 }, allow_nil: true
  validates :cash_pay, comparison: { greater_than_or_equal_to: :total }, if: :paying_in_cash?

  validate :allocation_must_be_active, on: :create
  validate :desk_allocation_must_be_available, on: :create

  after_validation :calculate_cash_change
  before_destroy :validate_order_completion, prepend: true

  scope :sales_by_date, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :unclosed, -> {
    includes(:allocation)
      .where("sell_orders.created_at < ?", Time.zone.today.beginning_of_day)
      .where(status: %i[ opened packed invoicing delivering ])
      .where(allocation: { active: true })
  }
  scope :current_sales_with_products, ->(statuses, kinds) {
    includes(:allocation, :bill, orders: { order_products: :product })
      .where(created_at: Time.zone.today.beginning_of_day..Time.current, status: statuses)
      .where(allocation: { kind: kinds, active: true })
  }
  scope :current_sales, ->(statuses, kinds) {
    joins(:allocation)
      .where(created_at: Time.zone.today.beginning_of_day..Time.current, status: statuses)
      .where(allocations: { kind: kinds, active: true })
  }
  scope :current_open_sales, -> {
    includes(orders: { order_products: :product })
    .where(created_at: Time.zone.today.beginning_of_day..Time.current,
           status: %i[ opened packed invoicing ])
  }

  def is_available_to_invoice?
    (opened? || packed? || (delivering? && !is_paid?)) && suborders_are_done?
  end

  def is_available_to_close?
    (invoicing? || delivering?) && is_paid?
  end

  def is_available_to_deliver?
    return true unless (delivering? || closed?) || !suborders_are_done? || !delivery_allocation?

    false
  end

  private

  def is_paid?
    case payment_type
    when "cash"
      (total && cash_pay && cash_change) ? true : false
    when "transfer", "card"
      total.present?
    else
      false
    end
  end

  def calculate_cash_change
    if invoicing? && (transfer? || card?)
      self.cash_pay = nil
      self.cash_change = nil
      return
    end
    return unless invoicing? && paying_in_cash? && cash_pay.present? && total

    self.cash_change = cash_pay - total
  end

  def delivery_allocation?
    allocation.delivery?
  end

  def complete_orders
    return unless persisted?

    Rails.logger.info "Calling CompleteOrdersJob for sell_order_id #{id}"
    CompleteOrdersJob.perform_later(id)
  end

  def create_bill
    return unless persisted?

    Rails.logger.info "Calling CreateBillJob for sell_order_id #{id}"
    CreateBillJob.perform_now(id)
  end

  def validate_order_completion
    return if orders.empty?

    target_set = %w[ processing packed completed ]
    order_statuses = orders.map(&:status)
    if order_statuses.any? { |order_status| target_set.include?(order_status) }
      errors.add(:base, "This record cannot be deleted because there are orders in process or completed")

      throw(:abort)
    end
  end

  def paying_in_cash?
    cash? && total
  end

  def suborders_are_done?
    statuses = orders.map(&:status).uniq
    return false unless statuses.one?

    statuses.first == "packed" || statuses.first == "completed"
  end

  def allocation_must_be_active
    unless allocation&.active?
      errors.add(:allocation, "must be active")
    end
  end

  def desk_allocation_must_be_available
    if allocation&.desk? && !allocation.available?
      errors.add(:allocation, "must be available")
    end
  end
end
