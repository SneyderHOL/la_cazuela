class PrepareOrderProductsJob < ApplicationJob
  queue_as :orders

  def perform(order)
    return unless order&.processing?

    Rails.logger.info "Preparing order_products for order_id #{order.id}"
    order.order_products.each(&:prepare!)
  end
end
