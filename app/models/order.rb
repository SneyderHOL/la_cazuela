# == Schema Information
#
# Table name: orders
# Database name: primary
#
#  id            :bigint           not null, primary key
#  status        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sell_order_id :bigint           not null
#
# Indexes
#
#  index_orders_on_sell_order_id  (sell_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (sell_order_id => sell_orders.id)
#
class Order < ApplicationRecord
  include OrderAasm

  belongs_to :sell_order
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products

  accepts_nested_attributes_for :order_products, allow_destroy: true

  validates :status, presence: true
  validate :must_have_products, on: :create
  validate :parent_sell_order_must_be_opened, on: :create

  before_destroy :check_status

  scope :current, -> {
    where(created_at: Time.zone.today.beginning_of_day..Time.current)
  }
  scope :current_open, -> {
    current.where(status: %i[ opened processing ])
  }
  scope :recent, ->(statuses = %i[ opened processing packed completed ]) {
    includes(order_products: :product, sell_order: :allocation)
      .where(created_at: Time.zone.today.beginning_of_day..Time.current, status: statuses)
  }

  private

  def ready_to_cook_order_products
    return unless persisted?

    Rails.logger.info "Calling ReadyToCookOrderProductsJob for order_id #{id}"
    ReadyToCookOrderProductsJob.perform_now(id)
  end

  def complete_order_products
    return unless persisted?

    Rails.logger.info "Calling CompleteOrderProductsJob for order_id #{id}"
    CompleteOrderProductsJob.perform_later(id)
  end

  def check_status
    throw :abort unless opened?
  end

  def must_have_products
    if order_products.reject(&:marked_for_destruction?).empty?
      errors.add(:order_products, "must contain at least one product")
    end
  end

  def parent_sell_order_must_be_opened
    unless sell_order&.opened?
      errors.add(:sell_order, "must be opened")
    end
  end
end
