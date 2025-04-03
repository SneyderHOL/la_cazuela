class Recipe < ApplicationRecord
  include RecipeAasm

  has_many :ingredient_recipes
  has_many :ingredients, through: :ingredient_recipes

  validates :name, :status, presence: true
end
