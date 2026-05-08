class CompleteOrderProductsJob < ApplicationJob
  queue_as :orders

  def perform(order)
    return unless order&.completed? || order&.packed?

    Rails.logger.info "Completing order_products for order_id #{order.id}"
    order.order_products.each(&:complete!)
  end
end
