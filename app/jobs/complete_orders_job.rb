class CompleteOrdersJob < ApplicationJob
  queue_as :sell_orders

  def perform(sell_order)
    return unless sell_order&.closed?

    Rails.logger.info "Completing orders for sell_order_id #{sell_order.id}"
    sell_order.orders.each(&:complete!)
  end
end
