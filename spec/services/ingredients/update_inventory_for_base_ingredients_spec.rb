require 'rails_helper'

RSpec.describe Ingredients::UpdateInventoryForBaseIngredients, type: :service do
  subject(:update_inventory_base_ingredient) { described_class.new(base_ingredient, kind) }

  describe '#call' do
    let(:base_ingredient) { create(:ingredient, :with_base_type, stored_quantity: 100) }
    let(:kind) { :addition }
    let(:recipe) { create(:recipe, :as_approved, ingredient: base_ingredient) }
    let(:ingredient_recipe) do
      create(:ingredient_recipe, required_quantity: 10, ingredient: preingredient, recipe: recipe)
    end

    context "with a valid base ingredient and addition kind the stored_quantity of the "\
      "ingredient gets an added" do
        let(:preingredient) { create(:ingredient, stored_quantity: 10) }

      before do
        ingredient_recipe
        update_inventory_base_ingredient.call
        preingredient.reload
      end

      it "updates the stored_quantity to the related ingredient" do
        expect(preingredient.stored_quantity).to be(20)
      end

      it { is_expected.to be_succeeded }
    end

    context "with a valid base ingredient and substraction kind the required_quantity of the "\
      "ingredient_recipes does not exceeds the stored_quantity" do
        let(:preingredient) { create(:ingredient, stored_quantity: 10) }
        let(:kind) { :substraction }

      before do
        ingredient_recipe
        update_inventory_base_ingredient.call
        preingredient.reload
      end

      it "updates the stored_quantity to the related ingredient" do
        expect(preingredient.stored_quantity).to be(0)
      end

      it { is_expected.to be_succeeded }
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context "with a valid base ingredient and the required_quantity of the "\
      "ingredient_recipes does exceeds the stored_quantity" do
        let(:preingredient) { create(:ingredient, stored_quantity: 9) }
        let(:kind) { :substraction }
        let(:error_message) do
          "Validation failed: Stored quantity must be greater than or equal to 0 for "\
          "ingredient #{preingredient.name}"
        end

        before { ingredient_recipe }

        it "raised an InventoryTransaction::InsufficientBaseStockError Exception" do
          expect { update_inventory_base_ingredient.call }.to raise_error(
            InventoryTransaction::InsufficientBaseStockError, error_message
          )
        end

      it "does not update the stored_quantity to the related ingredient" do
        expect(preingredient.reload.stored_quantity).to be(9)
      end

      it { is_expected.not_to be_succeeded }
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
