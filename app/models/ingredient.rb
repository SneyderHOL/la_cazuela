class Ingredient < ApplicationRecord
  include IngredientAasm

  has_many :ingredient_recipes
  has_many :recipes, through: :ingredient_recipes

  enum :unit, { ml: 0, mg: 1 }

  validates :name, :unit, :status, presence: true
  validates :stored_quantity, numericality: { greater_than_or_equal_to: 0 }
end
