class Order < ApplicationRecord
  include OrderAasm

  belongs_to :allocation
  belongs_to :parent, class_name: "Order", optional: true
  has_many :suborders, class_name: "Order", foreign_key: "parent_id"
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products

  validates :status, presence: true
  validate :parent_status_cannot_be_closed, on: :create
  validate :parent_assignation

  before_destroy :check_status

  private

  def delivery_allocation?
    allocation.delivery?
  end

  def prepare_order_products
    return unless persisted?

    Rails.logger.info "Calling PrepareOrderProductsJob for order_id #{id}"
    PrepareOrderProductsJob.perform_later(self)
  end

  def complete_order_products
    return unless persisted?

    Rails.logger.info "Calling CompleteOrderProductsJob for order_id #{id}"
    CompleteOrderProductsJob.perform_later(self)
  end

  def close_suborders
    return unless persisted? && parent_id.nil?

    Rails.logger.info "Calling CloseSubordersJob for order_id #{id}"
    CloseSubordersJob.perform_later(self)
  end

  def create_bill
    return unless persisted? && parent_id.nil?

    Rails.logger.info "Calling CreateBillJob for order_id #{id}"
    CreateBillJob.perform_later(self)
  end

  def parent_status_cannot_be_closed
    return unless parent&.closed?

    errors.add(:parent, "is a closed parent order")
  end

  def parent_assignation
    return unless parent&.parent_id

    errors.add(:parent, "cannot be a suborder")
  end

  def check_status
    return if opened?

    throw :abort
  end
end
