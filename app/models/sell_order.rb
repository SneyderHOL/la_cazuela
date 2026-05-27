class SellOrder < ApplicationRecord
  include SellOrderAasm

  belongs_to :allocation
  has_many :orders
  has_one :bill

  enum :payment_type, { cash: "cash", transfer: "transfer", card: "card" }

  validates :status, presence: true
  validates :total, numericality: { greater_than: 0 }, allow_nil: true
  validates :cash_pay, comparison: { greater_than_or_equal_to: :total }, if: :paying_in_cash?

  before_destroy :check_orders

  def calculate_cash_change
    return unless invoicing? && bill && paying_in_cash?

    self.cash_change = cash_pay - total
    self.save
  end

  private

  def enable_to_close?
    case payment_type
    when "cash"
      (total && cash_pay && cash_change) ? true : false
    when "transfer", "card"
      total ? true : false
    else
      false
    end
  end

  def delivery_allocation?
    allocation.delivery?
  end

  def complete_orders
    return unless persisted?

    Rails.logger.info "Calling CompleteOrdersJob for sell_order_id #{id}"
    CompleteOrdersJob.perform_later(self)
  end

  def create_bill
    return unless persisted?

    Rails.logger.info "Calling CreateBillJob for sell_order_id #{id}"
    CreateBillJob.perform_later(self)
  end

  def check_orders
    throw :abort unless orders.empty?
  end

  def paying_in_cash?
    cash? && total && cash_pay
  end
end
