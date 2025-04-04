class Recipe < ApplicationRecord
  include RecipeAasm

  belongs_to :product, optional: true
  has_many :ingredient_recipes
  has_many :ingredients, through: :ingredient_recipes
  # does not guarantees referencial integrity - not a foreign_key
  has_many :order_products

  validates :name, :status, presence: true
  validates :product_id, uniqueness: true, allow_nil: true
end
