# == Schema Information
#
# Table name: orders
# Database name: primary
#
#  id            :bigint           not null, primary key
#  status        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sell_order_id :bigint           not null
#
# Indexes
#
#  index_orders_on_sell_order_id  (sell_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (sell_order_id => sell_orders.id)
#
class Order < ApplicationRecord
  include AASM

  aasm column: "status" do
    state :opened, initial: true
    state :processing, :packed, :completed

    event :confirm do
      after do
        ready_to_cook_order_products
      end
      transitions from: :opened, to: :processing
    end

    event :pack do
      after do
        complete_order_products
      end
      transitions from: :processing, to: :packed
    end

    event :complete do
      after do
        complete_order_products
      end
      transitions from: :processing, to: :completed
    end
  end

  belongs_to :sell_order
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products

  accepts_nested_attributes_for :order_products, allow_destroy: true

  validates :status, presence: true
  validate :parent_sell_order_must_be_opened, on: :create

  before_destroy :check_status, prepend: true
  before_destroy :validate_order_product_in_process, prepend: true

  scope :current, -> {
    where(created_at: Time.zone.today.beginning_of_day..Time.current)
  }
  scope :current_open, -> {
    current.where(status: %i[ opened processing ])
  }
  scope :recent, ->(statuses = %i[ opened processing packed completed ]) {
    includes(order_products: :product, sell_order: :allocation)
      .where(created_at: Time.zone.today.beginning_of_day..Time.current, status: statuses)
  }

  private

  def ready_to_cook_order_products
    return unless persisted?

    Rails.logger.info "Calling ReadyToCookOrderProductsJob for order_id #{id}"
    ReadyToCookOrderProductsJob.perform_now(id)
  end

  def complete_order_products
    return unless persisted?

    Rails.logger.info "Calling CompleteOrderProductsJob for order_id #{id}"
    CompleteOrderProductsJob.perform_later(id)
  end

  def check_status
    return if opened? || processing?

    errors.add(:base, "This record cannot be deleted because is not opened or processing")
    throw(:abort)
  end

  def validate_order_product_in_process
    preparation_statuses = order_products.map(&:status)
    if preparation_statuses.include?("preparing") || preparation_statuses.include?("completed")
      errors.add(:base, "This record cannot be deleted because there are preparations in process or completed")

      throw(:abort)
    end
  end

  def parent_sell_order_must_be_opened
    unless sell_order&.opened?
      errors.add(:sell_order, "must be opened")
    end
  end
end
