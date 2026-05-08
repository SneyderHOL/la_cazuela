class CreateBillJob < ApplicationJob
  queue_as :sell_orders

  def perform(sell_order)
    return unless sell_order&.closed?

    Rails.logger.info "Creating Bill for sell_order_id #{sell_order.id}"
    SellOrders::CreateBill.new(sell_order).call
  end
end
