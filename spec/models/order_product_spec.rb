require 'rails_helper'

RSpec.describe OrderProduct, type: :model do
  subject(:order_product_object) { build(:order_product, :with_associations) }

  describe "factory object" do
    it 'is valid' do
      expect(order_product_object).to be_valid
      expect(order_product_object.order).not_to be_nil
      expect(order_product_object.product).not_to be_nil
      expect(order_product_object.quantity).not_to be_nil
      expect(order_product_object.status).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:recipe).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }

    describe "ingredient_availability" do
      let(:order_product) { build(:order_product, :with_order, product: product) }
      context "on create" do
        let(:product) { create(:product) }
        let(:stored_quantity) { 10 }
        let(:required_quantity) { 11 }
        let(:ingredient) { create(:ingredient, stored_quantity: stored_quantity) }
        let(:recipe) { create(:recipe, product: product) }
        let(:ingredient_recipe) do
          create(:ingredient_recipe, required_quantity: required_quantity,
            ingredient: ingredient, recipe: recipe)
        end
        let(:error_msg) { "Product is insufficient in #{ingredient.name}" }

        before do
          ingredient_recipe
          order_product.save
          ingredient.reload
        end

        it "does not updates the stored_quantity to the related ingredient" do
          expect(ingredient.stored_quantity).to eql(10)
        end

        it "does not save the order product object" do
          expect(order_product).not_to be_persisted
        end

        it "is invalid" do
          expect(order_product).not_to be_valid
        end

        it "has errors" do
          expect(order_product.errors).not_to be_empty
          expect(order_product.errors.full_messages).to include(error_msg)
        end
      end
    end
  end

  describe "callbacks" do
    describe "before_create" do
      describe "add_recipe" do
        let(:order_product) { build(:order_product, :with_order, product: product) }
        context "when parent product have a recipe_id" do
          let(:product) { create(:product, :with_recipe, trait_ingredient_recipe_amount: 2) }
          it "adds the recipe_id of the parent product" do
            expect(product.recipe.id).not_to be_nil
            order_product.save
            expect(order_product.recipe_id).not_to be_nil
            expect(order_product).to be_persisted
          end
        end

        context "when parent product does not have a recipe_id" do
          let(:product) { create(:product) }
          it "recipe_id is nil" do
            expect(product.recipe).to be_nil
            order_product.save
            expect(order_product.recipe_id).to be_nil
            expect(order_product).to be_persisted
          end
        end
      end
    end
  end

  describe "status transitions" do
    describe 'prepare' do
      before { order_product_object.status = 'to_prepare' }
      it do
        expect { order_product_object.prepare }.to change(
          order_product_object, :status).from("to_prepare").to("preparing")
      end
    end

    describe 'complete' do
      before { order_product_object.status = 'preparing' }
      it do
        expect { order_product_object.complete }.to change(
          order_product_object, :status).from("preparing").to("completed")
      end
    end
  end
end
