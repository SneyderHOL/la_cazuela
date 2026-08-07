require 'rails_helper'

# == Schema Information
#
# Table name: ingredient_recipes
# Database name: primary
#
#  id                :bigint           not null, primary key
#  required_quantity :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ingredient_id     :bigint           not null
#  recipe_id         :bigint           not null
#
# Indexes
#
#  index_ingredient_recipes_on_ingredient_id                (ingredient_id)
#  index_ingredient_recipes_on_ingredient_id_and_recipe_id  (ingredient_id,recipe_id) UNIQUE
#  index_ingredient_recipes_on_recipe_id                    (recipe_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (recipe_id => recipes.id)
#
RSpec.describe IngredientRecipe, type: :model do
  subject(:ingredient_recipe) { build(:ingredient_recipe, :with_associations) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it "ingredient is not nil" do
      expect(ingredient_recipe.ingredient).not_to be_nil
    end

    it "recipe is not nil" do
      expect(ingredient_recipe.recipe).not_to be_nil
    end

    it "required_quantity is not nil" do
      expect(ingredient_recipe.required_quantity).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:ingredient) }
    it { is_expected.to belong_to(:recipe) }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:required_quantity).is_greater_than(0) }
    it { is_expected.to validate_uniqueness_of(:ingredient_id).scoped_to(:recipe_id) }
  end
end
