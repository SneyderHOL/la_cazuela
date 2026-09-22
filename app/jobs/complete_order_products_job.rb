class CompleteOrderProductsJob < ApplicationJob
  queue_as :orders

  def perform(order_id)
    set_order(order_id)
    return unless @order&.completed? || @order&.packed?

    Rails.logger.info "Completing order_products for order_id #{@order.id}"
    @order.order_products.each do |order_product|
      order_product.complete! unless order_product.completed?
    end
  end

  private

  def set_order(id)
    @order = Order.includes(:order_products).find(id)
  end
end
