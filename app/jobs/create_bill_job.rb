class CreateBillJob < ApplicationJob
  queue_as :orders

  def perform(order)
    return unless order&.closed? && order&.parent_id.nil?

    Rails.logger.info "Creating Bill for order_id #{order.id}"
    Orders::CreateBill.new(order).call
  end
end
