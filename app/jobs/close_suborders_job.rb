class CloseSubordersJob < ApplicationJob
  queue_as :orders

  def perform(*args, order)
    return unless order&.closed? && order&.parent_id.nil?

    Rails.logger.info "Closing suborders for order_id #{order.id}"
    order.suborders.each(&:close!)
  end
end
