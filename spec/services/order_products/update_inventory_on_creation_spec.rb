require 'rails_helper'

RSpec.shared_examples "calls the CreateInventoryTransactionsJob" do
  it { expect(CreateInventoryTransactionsJob).to have_received(:perform_later) }
end

RSpec.shared_examples "not call the CreateInventoryTransactionsJob" do
  it { expect(CreateInventoryTransactionsJob).not_to have_received(:perform_later) }
end

RSpec.describe OrderProducts::UpdateInventoryOnCreation, type: :service do
  subject(:update_inventory_transaction_on_create) { described_class.new(order_product) }

  describe '#call' do
    let(:order_product) { build(:order_product, :with_order, product: product) }
    let(:product) { create(:product) }

    let(:recipe) { create(:recipe, product: product) }
    let(:ingredient_recipe) do
      create(:ingredient_recipe, required_quantity: 5,
        ingredient: ingredient, recipe: recipe
      )
    end

    before { allow(CreateInventoryTransactionsJob).to receive(:perform_later) }

    context "when parent product have a recipe with a non persisted order_product "\
      "and the required_quantity does not exceeds the stored_quantity" do
      let(:ingredient) { create(:ingredient, stored_quantity: 10) }

      before do
        ingredient_recipe
        update_inventory_transaction_on_create.call
        ingredient.reload
      end

      it "updates the stored_quantity to the related ingredient" do
        expect(ingredient.stored_quantity).to be(5)
      end

      it "saves the order_product record" do
        expect(order_product).to be_persisted
      end

      it { is_expected.to be_succeeded }

      it_behaves_like "calls the CreateInventoryTransactionsJob"
    end

    context "when parent product have a recipe with a non persisted order_product "\
      "and the required_quantity exceeds the stored_quantity" do
        let(:ingredient) { create(:ingredient, stored_quantity: 4) }

      it "does not update the stored_quantity to the related ingredient" do
        expect(ingredient.stored_quantity).to be(4)
      end

      it "does not save the order_product record" do
        expect(order_product).not_to be_persisted
      end

      it { is_expected.not_to be_succeeded }

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end

    context "when parent product have a recipe with a persisted order_product" do
      let(:ingredient) { create(:ingredient, stored_quantity: 10) }

      before do
        ingredient_recipe
        order_product.save
        update_inventory_transaction_on_create.call
        ingredient.reload
      end

      it "does not update the stored_quantity to the related ingredient" do
        expect(ingredient.stored_quantity).to be(10)
      end

      it { is_expected.not_to be_succeeded }

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end
  end
end
