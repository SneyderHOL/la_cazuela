class ReadyToCookOrderProductsJob < ApplicationJob
  queue_as :orders

  def perform(order)
    return unless order&.processing?

    Rails.logger.info "Ready to Cook order_products for order_id #{order.id}"
    order.order_products.each(&:ready_to_cook!)
  end
end
