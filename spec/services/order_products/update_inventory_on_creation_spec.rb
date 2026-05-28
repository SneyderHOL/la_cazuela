require 'rails_helper'

RSpec.describe OrderProducts::UpdateInventoryOnCreation, type: :service do
  subject(:update_inventory_transaction_on_create) { described_class.new(order_product) }

  describe '#call' do
    let(:recipe) { create(:recipe, :as_approved, product: create(:product, :with_category)) }
    let(:ingredient_recipe) do
      create(:ingredient_recipe, required_quantity: 5,
        ingredient: ingredient, recipe: recipe
      )
    end

    before do
      allow(CreateInventoryTransactionsJob).to receive(:perform_later)
      ingredient_recipe
      order_product
    end

    context "when parent product have a recipe with a non persisted order_product "\
      "and the required_quantity does not exceeds the stored_quantity" do
      let(:order_product) do
        build(:order_product, :with_order, product: recipe.product, quantity: 5)
      end
      let(:ingredient) { create(:ingredient, stored_quantity: 25) }

      before do
        update_inventory_transaction_on_create.call
        ingredient.reload
      end

      it "does not updates the stored_quantity to the related ingredient" do
        expect(ingredient.stored_quantity).to eq(25)
      end

      it "does not saves the order_product record" do
        expect(order_product).not_to be_persisted
      end

      it "does not update the order_product record" do
        expect(order_product.inventoried).to be_nil
      end

      it { is_expected.not_to be_succeeded }

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end

    context "when parent product have a recipe with a persisted order_product "\
      "and the required_quantity exceeds the stored_quantity" do
      let(:order_product) { create(:order_product, :with_order, product: recipe.product, quantity: 5) }
      let(:ingredient) { create(:ingredient, stored_quantity: 25) }

      before do
        ingredient.update(stored_quantity: 10)
        update_inventory_transaction_on_create.call
        ingredient.reload
      end

      it "does not update the stored_quantity to the related ingredient" do
        expect(ingredient.stored_quantity).to eq(10)
      end

      it "does not update the order_product record" do
        expect(order_product.reload.inventoried).to be_falsey
      end

      it { is_expected.not_to be_succeeded }

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end

    context "when parent product have a recipe with a persisted order_product" do
      let(:order_product) { create(:order_product, :with_order, product: recipe.product, quantity: 5) }
      let(:ingredient) { create(:ingredient, stored_quantity: 25) }

      before do
        update_inventory_transaction_on_create.call
        ingredient.reload
      end

      it "does not update the stored_quantity to the related ingredient" do
        expect(ingredient.reload.stored_quantity).to eq(0)
      end

      it "does not update the order_product record" do
        expect(order_product.reload.inventoried).to be_truthy
      end

      it { is_expected.to be_succeeded }

      it_behaves_like "calls the CreateInventoryTransactionsJob"
    end
  end
end
