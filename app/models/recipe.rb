class Recipe < ApplicationRecord
  include RecipeAasm

  belongs_to :product, optional: true
  has_many :ingredient_recipes
  has_many :ingredients, through: :ingredient_recipes

  validates :name, :status, presence: true
  validates :product_id, uniqueness: true, allow_nil: true
end
