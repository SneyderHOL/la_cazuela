class ReadyToCookOrderProductsJob < ApplicationJob
  queue_as :orders

  def perform(order_id)
    set_order(order_id)
    return unless @order&.processing?

    Rails.logger.info "Ready to Cook order_products for order_id #{@order.id}"
    @order.order_products.each do |order_product|
      order_product.ready_to_cook! if order_product.requested?
    end
  end

  private

  def set_order(id)
    @order = Order.includes(:order_products).find(id)
  end
end
