# == Schema Information
#
# Table name: ingredients
# Database name: primary
#
#  id              :bigint           not null, primary key
#  cost            :integer          default(0), not null
#  high_threshold  :integer          default(0), not null
#  ingredient_type :string           default("regular"), not null
#  low_threshold   :integer          default(0), not null
#  name            :string           not null
#  status          :string           not null
#  stored_quantity :integer          not null
#  unit            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_ingredients_on_name  (name) UNIQUE
#
class Ingredient < ApplicationRecord
  include IngredientAasm

  VALID_INGREDIENT_TYPES = %w[regular base material].freeze

  # For base ingredients only
  has_one :recipe, dependent: :restrict_with_error
  has_many :ingredient_recipes, dependent: :restrict_with_error
  has_many :recipes, through: :ingredient_recipes

  enum :unit, { ml: 0, mg: 1, one: 2 }
  enum :ingredient_type, { regular: "regular", base: "base", material: "material" }, default: :regular

  validates :name, :unit, :status, :ingredient_type, presence: true
  validates :name, uniqueness: true
  validates :stored_quantity, :low_threshold, :high_threshold, :cost,
            numericality: { greater_than_or_equal_to: 0 }

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
