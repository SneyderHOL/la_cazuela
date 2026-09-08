class OrderCompletionJob < ApplicationJob
  queue_as :orders

  def perform(order)
    return unless order&.processing?

    incomplete_order_products = order.order_products.where(
      status: %w[ requested prepare preparing ]
    )
    return if incomplete_order_products.any?

    allocation = order.sell_order.allocation
    if allocation.desk?
      Rails.logger.info "Completing order for order_id #{order.id}"
      order.complete!
    else
      Rails.logger.info "Packing order for order_id #{order.id}"
      order.pack!
    end
  end
end
