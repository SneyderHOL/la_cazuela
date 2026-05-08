class SellOrder < ApplicationRecord
  include SellOrderAasm

  belongs_to :allocation
  has_many :orders
  has_one :bill

  enum :payment_type, { cash: "cash", transfer: "transfer", card: "card" }
  validates :status, presence: true

  before_destroy :check_orders

  private

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
end
