class OrderProduct < ApplicationRecord
  class TransactionCompletedError < StandardError; end

  include OrderProductAasm

  belongs_to :order
  belongs_to :product
  # does not guarantees referencial integrity - not a foreign_key
  belongs_to :recipe, optional: true

  validates :status, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validate :ingredient_availability, on: :create

  before_create :add_recipe

  private

  def ingredient_availability
    return unless product&.recipe

    error_msg = nil
    product.recipe.ingredient_recipes.each do |ingredient_recipe|
      break if error_msg

      remaining_quantity = ingredient_recipe.ingredient.stored_quantity -
        ingredient_recipe.required_quantity

      if remaining_quantity.negative?
        error_msg = "is insufficient in #{ingredient_recipe.ingredient.name}"
      end
    end

    return unless error_msg

    errors.add(:product, error_msg)
  end

  # keeps track of the recipe used
  def add_recipe
    self.recipe_id = product.recipe&.id
  end
end
