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
  # validate :must_have_products

  before_destroy :check_status

  scope :current_open, -> {
    where(created_at: Time.zone.today.beginning_of_day..Time.current,
          status: %i[ opened processing ])
  }
  scope :recent, -> {
    includes(:order_products, sell_order: :allocation)
      .where(created_at: Time.zone.today.beginning_of_day..Time.current)
      .order(created_at: :desc)
  }

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

  def must_have_products
    if order_products.reject(&:marked_for_destruction?).empty?
      errors.add(:order_products, "must contain at least one product")
    end
  end
end
