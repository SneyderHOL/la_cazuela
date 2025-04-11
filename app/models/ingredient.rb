class Ingredient < ApplicationRecord
  include IngredientAasm

  VALID_INGREDIENT_TYPES = %w[regular base].freeze

  has_one :recipe
  has_many :ingredient_recipes
  has_many :recipes, through: :ingredient_recipes

  enum :unit, { ml: 0, mg: 1, one: 2 }

  validates :name, :unit, :status, :ingredient_type, presence: true
  validates :ingredient_type, inclusion: VALID_INGREDIENT_TYPES
  validates :stored_quantity, numericality: { greater_than_or_equal_to: 0 }

  def base_type?
    ingredient_type == "base"
  end
end
