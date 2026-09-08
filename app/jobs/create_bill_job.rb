class CreateBillJob < ApplicationJob
  queue_as :sell_orders

  def perform(sell_order_id)
    set_sell_order(sell_order_id)
    return unless @sell_order&.closed? || @sell_order&.invoicing?

    Rails.logger.info "Creating Bill for sell_order_id #{@sell_order.id}"
    SellOrders::CreateBill.new(@sell_order).call
  end

  private

  def set_sell_order(id)
    @sell_order = SellOrder.includes(orders: { order_products: :product }).find(id)
  end
end
