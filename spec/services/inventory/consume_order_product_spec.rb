require 'rails_helper'

RSpec.describe Inventory::ConsumeOrderProduct, type: :service do
  subject(:consume_order_product) { described_class.new(order_product) }

  describe '#call' do
    let(:recipe) { create(:recipe, :as_approved, product: create(:product, :with_category)) }
    let(:ingredient_recipe) do
      create(:ingredient_recipe, required_quantity: 5,
        ingredient: ingredient, recipe: recipe
      )
    end

    before do
      ingredient_recipe
      order_product
    end

    context "when parent product have a recipe with an order_product "\
      "and the required_quantity exceeds the stored_quantity" do
      let(:order_product) { create(:order_product, :with_order, product: recipe.product, quantity: 5) }
      let(:ingredient) { create(:ingredient, stored_quantity: 25) }

      before do
        ingredient.update(stored_quantity: 10)
      end

      it "raise Inventory::ConsumeOrderProduct::InsufficientStockError" do
        expect { consume_order_product.call }.to raise_error(
          Inventory::ConsumeOrderProduct::InsufficientStockError,
          "#{ingredient.name} has insufficient stock"
        )
      end
    end

    context "when parent product have a recipe with an order_product "\
      "and was already consumed" do
      let(:order_product) { create(:order_product, :with_order, product: recipe.product, quantity: 5) }
      let(:ingredient) { create(:ingredient, stored_quantity: 25) }

      before do
        order_product.update(inventory_consumed_at: Time.current)
      end

      it "raise Inventory::ConsumeOrderProduct::InsufficientStockError" do
        expect { consume_order_product.call }.to raise_error(
          Inventory::ConsumeOrderProduct::AlreadyConsumedError
        )
      end
    end

    context "when parent product have a recipe with an order_product "\
      "with missing recipe" do
      let(:order_product) { create(:order_product, :with_order, product: recipe.product, quantity: 5) }
      let(:ingredient) { create(:ingredient, stored_quantity: 25) }

      before do
        order_product.update(recipe: nil)
      end

      it "raise Inventory::ConsumeOrderProduct::InsufficientStockError" do
        expect { consume_order_product.call }.to raise_error(
          Inventory::ConsumeOrderProduct::MissingRecipeError
        )
      end
    end

    context "when parent product have a recipe with a order_product" do
      let(:order_product) { create(:order_product, :with_order, product: recipe.product, quantity: 5) }
      let(:ingredient) { create(:ingredient, stored_quantity: 25, cost: 1_000) }

      before do
        consume_order_product
        ingredient
      end

      it do
        expect { consume_order_product.call }.to change(
          InventoryTransaction, :count).from(0).to(1)
      end

      it "does update the stored_quantity to the related ingredient" do
        consume_order_product.call
        expect(ingredient.reload.stored_quantity).to eq(0)
      end

      it "does update the cost to the related ingredient" do
        consume_order_product.call
        expect(ingredient.reload.cost).to eq(0)
      end

      it "does update the order_product record" do
        consume_order_product.call
        expect(order_product.reload.inventory_consumed_at).to be_present
      end
    end
  end
end
