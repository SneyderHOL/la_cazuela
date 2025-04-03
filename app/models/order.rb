class Order < ApplicationRecord
  include OrderAasm

  has_many :suborders, class_name: "Order", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Order", optional: true

  validates :status, presence: true
  validate :parent_status_cannot_be_closed, on: :create
  validate :parent_assignation

  private

  def close_suborders
    return unless persisted? && parent_id.nil?

    Rails.logger.info "Calling CloseSubordersJob for order_id #{id}"
    CloseSubordersJob.perform_later(self)
    Rails.logger.info "CloseSubordersJob called"
  end

  def parent_status_cannot_be_closed
    return unless parent&.closed?

    errors.add(:parent, "is a closed parent order")
  end

  def parent_assignation
    return unless parent&.parent_id

    errors.add(:parent, "is cannot be a suborder")
  end
end
