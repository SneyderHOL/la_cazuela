# == Schema Information
#
# Table name: recipes
# Database name: primary
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  output_quantity :integer          default(1), not null
#  status          :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  ingredient_id   :bigint
#  product_id      :bigint
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
  include AASM

  aasm column: "status" do
    state :drafting, initial: true
    state :declined, :approved

    event :approve do
      transitions from: %i[ drafting declined ], to: :approved
    end

    event :decline do
      transitions from: %i[ drafting approved ], to: :declined
    end

    event :draft do
      transitions from: :declined, to: :drafting
    end
  end

  belongs_to :product, optional: true
  belongs_to :ingredient, optional: true

  has_many :ingredient_recipes
  has_many :ingredients, through: :ingredient_recipes

  # does not guarantees referencial integrity - not a foreign_key
  has_many :order_products

  validates :name, :status, presence: true
  # output_quantity is the amount of the recipe's associated to produced a product or
  # base ingredient by one execution of the recipe.
  validates :output_quantity, numericality: { greater_than: 0 }
  validates :name, uniqueness: true
  validate :approved_recipe_for_associations
  validate :it_belongs_only_to_one_association
  validate :ingredient_with_correct_type
  validate :ingredient_association_included_in_recipe?
  validates :product_id, uniqueness: true, allow_nil: true
  validates :ingredient_id, uniqueness: true, allow_nil: true

  # estimated ingredients cost of producing one product or the output_quantity for a
  # base ingredient
  def cost
    ingredient_recipes.sum(&:cost)
  end

  # cost per unit of the base ingredient produced
  def unit_cost
    return 0.to_d if output_quantity.zero?

    cost.to_d / output_quantity
  end

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
