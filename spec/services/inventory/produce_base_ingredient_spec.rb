require 'rails_helper'

RSpec.describe Inventory::ProduceBaseIngredient, type: :service do
  subject(:produce_base_ingredient) { described_class.new(base_ingredient, 200) }

  describe '#call' do
    let(:base_ingredient) { create(:ingredient, :with_base_type, stored_quantity: 100) }
    let(:recipe) { create(:recipe, :as_approved, ingredient: base_ingredient, output_quantity: 200) }
    let(:ingredient_recipe) do
      create(:ingredient_recipe, required_quantity: 10, ingredient: preingredient, recipe: recipe)
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context "with a valid base ingredient the stored_quantity of the "\
      "ingredient gets an added" do
      let(:preingredient) { create(:ingredient, stored_quantity: 10, cost: 100) }
      let(:preingredient2) { create(:ingredient, stored_quantity: 20, cost: 100) }
      let(:ingredient_recipe2) do
        create(:ingredient_recipe, required_quantity: 20, ingredient: preingredient2, recipe: recipe)
      end

      before do
        ingredient_recipe
        ingredient_recipe2
        produce_base_ingredient.call
        preingredient.reload
        preingredient2.reload
      end

      it "updates the stored_quantity to the related ingredient" do
        expect(preingredient.stored_quantity).to be(0)
      end

      it "updates the cost to the related ingredient" do
        expect(preingredient.cost).to be(0)
      end

      it "updates the stored_quantity to the other related ingredient" do
        expect(preingredient2.stored_quantity).to be(0)
      end

      it "updates the cost to the related other ingredient" do
        expect(preingredient2.cost).to be(0)
      end

      it { expect(produce_base_ingredient.production_cost).to be(200) }
    end

    context "with a valid base ingredient and the required_quantity of the "\
      "ingredient_recipes does exceeds the stored_quantity" do
      let(:preingredient) { create(:ingredient, stored_quantity: 9) }
      let(:error_message) do
        "#{preingredient.name} has insufficient stock (required: "\
        "#{ingredient_recipe.required_quantity}, "\
        "available: #{preingredient.stored_quantity})"
      end

      before { ingredient_recipe }

      it "raised an Inventory::ProduceBaseIngredient::InsufficientStockError Exception" do
        expect { produce_base_ingredient.call }.to raise_error(
          Inventory::ProduceBaseIngredient::InsufficientStockError, error_message
        )
      end

      # rubocop:disable RSpec/MultipleExpectations
      it "does not update the stored_quantity to the related ingredient" do
        expect { produce_base_ingredient.call }.to raise_error(
          Inventory::ProduceBaseIngredient::InsufficientStockError, error_message
        )
        expect(preingredient.reload.stored_quantity).to be(9)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
