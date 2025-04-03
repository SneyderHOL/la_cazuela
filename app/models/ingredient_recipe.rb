class IngredientRecipe < ApplicationRecord
  belongs_to :ingredient
  belongs_to :recipe

  validates :required_quantity, numericality: { greater_than: 0 }
  validates :ingredient_id, uniqueness: { scope: :recipe_id }
end
