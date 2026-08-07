# == Schema Information
#
# Table name: recipes
# Database name: primary
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  status        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint
#  product_id    :bigint
#
# Indexes
#
#  index_recipes_on_ingredient_id  (ingredient_id) UNIQUE
#  index_recipes_on_name           (name) UNIQUE
#  index_recipes_on_product_id     (product_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (product_id => products.id)
#
class Recipe < ApplicationRecord
  include RecipeAasm

  belongs_to :product, optional: true
  belongs_to :ingredient, optional: true
  has_many :ingredient_recipes
  has_many :ingredients, through: :ingredient_recipes

  # does not guarantees referencial integrity - not a foreign_key
  has_many :order_products

  validates :name, :status, presence: true
  validates :name, uniqueness: true
  validate :approved_recipe_for_associations
  validate :it_belongs_only_to_one_association
  validate :ingredient_with_correct_type
  validate :ingredient_association_included_in_recipe?
  validates :product_id, uniqueness: true, allow_nil: true
  validates :ingredient_id, uniqueness: true, allow_nil: true

  private

  def approved_recipe_for_associations
    return unless (product_id || ingredient_id) && !approved?

    errors.add(:base, :invalid, message: "This Recipe has not been approved")
  end

  def it_belongs_only_to_one_association
    return unless product_id && ingredient_id

    errors.add(
      :base,
      :invalid,
      message: "This Recipe can only be associated with a Product or an Ingredient"
    )
  end

  def ingredient_with_correct_type
    return unless ingredient && (ingredient.regular? || ingredient.material?)

    errors.add(:ingredient, "is not a base type")
  end

  def ingredient_association_included_in_recipe?
    return unless ingredient_id && ingredient_id_changed? && ingredients.map(&:id).include?(ingredient_id)

    errors.add(:ingredient, "is already included within the recipe's ingredient list")
  end
end
