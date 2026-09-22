class CompleteOrdersJob < ApplicationJob
  queue_as :sell_orders

  def perform(sell_order_id)
    set_sell_order(sell_order_id)
    return unless @sell_order&.closed?

    allocation = @sell_order.allocation
    if allocation.desk?
      Rails.logger.info "Completing orders for sell_order_id #{@sell_order.id}"
      @sell_order.orders.each { |order| order.complete! unless order.completed? }
    else
      Rails.logger.info "Packing orders for sell_order_id #{@sell_order.id}"
      @sell_order.orders.each { |order| order.pack! unless order.packed? }
    end
  end

  private

  def set_sell_order(id)
    @sell_order = SellOrder.includes(:orders, :allocation).find(id)
  end
end
