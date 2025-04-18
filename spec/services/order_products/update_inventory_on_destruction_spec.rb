require 'rails_helper'

RSpec.describe OrderProducts::UpdateInventoryOnDestruction, type: :service do
  subject(:update_inventory_transaction_on_destroy) { described_class.new(order_product) }

  describe '#call' do
    let(:recipe) { create(:recipe, :as_approved, product: create(:product)) }
    let(:order_product) { create(:order_product, :with_order, product: recipe.product, quantity: 5) }
    let(:ingredient_recipe) do
      create(:ingredient_recipe, required_quantity: 5,
        ingredient: ingredient, recipe: recipe
      )
    end

    before { allow(CreateInventoryTransactionsJob).to receive(:perform_later) }

    context "when parent product have a recipe with a persisted order_product" do
      let(:ingredient) { create(:ingredient, stored_quantity: 125) }

      before do
        ingredient_recipe
        update_inventory_transaction_on_destroy.call
        ingredient.reload
      end

      it "updates the stored_quantity to the related ingredient" do
        expect(ingredient.stored_quantity).to be(150)
      end

      it "destroy the order_product record" do
        expect(order_product).not_to be_persisted
      end

      it { is_expected.to be_succeeded }

      it_behaves_like "calls the CreateInventoryTransactionsJob"
    end

    context "when parent product have a recipe with a non persisted order_product" do
      let(:ingredient) { create(:ingredient, stored_quantity: 100) }

      before do
        ingredient_recipe
        order_product.destroy
        update_inventory_transaction_on_destroy.call
        ingredient.reload
      end

      it "does not update the stored_quantity to the related ingredient" do
        expect(ingredient.stored_quantity).to be(100)
      end

      it { is_expected.not_to be_succeeded }

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end
  end
end
