# == Schema Information
#
# Table name: order_products
# Database name: primary
#
#  id          :bigint           not null, primary key
#  inventoried :boolean
#  note        :string
#  quantity    :integer          not null
#  status      :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  order_id    :bigint           not null
#  product_id  :bigint           not null
#  recipe_id   :bigint
#
# Indexes
#
#  index_order_products_on_order_id    (order_id)
#  index_order_products_on_product_id  (product_id)
#  index_order_products_on_recipe_id   (recipe_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (product_id => products.id)
#
class OrderProduct < ApplicationRecord
  include OrderProductAasm

  belongs_to :order
  belongs_to :product
  # does not guarantees referencial integrity - not a foreign_key
  belongs_to :recipe, optional: true

  validates :status, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validate :ingredient_availability, on: :create

  before_create :add_recipe

  scope :current_preparations, -> {
    where(created_at: Time.zone.today.beginning_of_day..Time.current)
  }
  scope :current_preparations_with_sell_orders, ->(statuses) {
    includes(:product, order: { sell_order: :allocation })
      .where(created_at: Time.zone.today.beginning_of_day..Time.current,
             status: statuses)
  }
  scope :current_preparations_counting, -> { current_preparations.group(:status).count }

  private

  def ingredient_availability
    return unless product&.recipe

    error_msg = nil
    product.recipe.ingredient_recipes.each do |ingredient_recipe|
      break if error_msg

      remaining_quantity = ingredient_recipe.ingredient.stored_quantity -
                           (ingredient_recipe.required_quantity * quantity)

      next if remaining_quantity.zero? || remaining_quantity.positive?

      error_msg = "is insufficient in #{ingredient_recipe.ingredient.name}"
    end

    return unless error_msg

    errors.add(:product, error_msg)
  end

  # keeps track of the recipe used
  def add_recipe
    self.recipe_id = product.recipe&.id
  end
end
