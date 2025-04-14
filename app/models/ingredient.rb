class Ingredient < ApplicationRecord
  include IngredientAasm

  VALID_INGREDIENT_TYPES = %w[regular base material].freeze

  has_one :recipe
  has_many :ingredient_recipes
  has_many :recipes, through: :ingredient_recipes

  enum :unit, { ml: 0, mg: 1, one: 2 }

  validates :name, :unit, :status, :ingredient_type, presence: true
  validates :ingredient_type, inclusion: VALID_INGREDIENT_TYPES
  validates :stored_quantity, :low_threshold, :high_threshold,
            numericality: { greater_than_or_equal_to: 0 }

  def base_type?
    ingredient_type == "base"
  end

  def regular_type?
    ingredient_type == "regular"
  end

  def material_type?
    ingredient_type == "material"
  end

  def stock_level
    return "undefined" if low_threshold >= high_threshold

    if stored_quantity >= high_threshold
      "high"
    elsif stored_quantity >= low_threshold
      "medium"
    elsif stored_quantity.zero?
      "empty"
    else
      "low"
    end
  end
end
