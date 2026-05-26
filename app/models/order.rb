class Order < ApplicationRecord
  include OrderAasm

  belongs_to :sell_order
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products

  validates :status, presence: true

  before_destroy :check_status

  private

  def ready_to_cook_order_products
    return unless persisted?

    Rails.logger.info "Calling ReadyToCookOrderProductsJob for order_id #{id}"
    ReadyToCookOrderProductsJob.perform_later(self)
  end

  def complete_order_products
    return unless persisted?

    Rails.logger.info "Calling CompleteOrderProductsJob for order_id #{id}"
    CompleteOrderProductsJob.perform_later(self)
  end

  def check_status
    throw :abort unless opened?
  end
end
