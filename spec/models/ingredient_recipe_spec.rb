require 'rails_helper'

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
