require 'rails_helper'

RSpec.describe OrderProduct, type: :model do
  subject(:order_product_object) { build(:order_product, :with_associations) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'order is not nil' do
      expect(order_product_object.order).not_to be_nil
    end

    it 'product is not nil' do
      expect(order_product_object.product).not_to be_nil
    end

    it 'quantity is not nil' do
      expect(order_product_object.quantity).not_to be_nil
    end

    it 'status is not nil' do
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

    describe "ingredient_availability on create" do
      let(:order_product) { build(:order_product, :with_order, product: product) }
      let(:product) { create(:product) }
      let(:ingredient) { create(:ingredient, stored_quantity: 10) }
      let(:recipe) { create(:recipe, :as_approved, product: product) }
      let(:ingredient_recipe) do
        create(:ingredient_recipe, required_quantity: 11,
          ingredient: ingredient, recipe: recipe)
      end

      before do
        ingredient_recipe
        order_product.save
        ingredient.reload
      end

      it "does not updates the stored_quantity to the related ingredient" do
        expect(ingredient.stored_quantity).to be(10)
      end

      it "does not save the order product object" do
        expect(order_product).not_to be_persisted
      end

      it "is invalid" do
        expect(order_product).not_to be_valid
      end

      it "has errors" do
        expect(order_product.errors).not_to be_empty
      end

      it "has error message" do
        expect(order_product.errors.full_messages).to include(
          "Product is insufficient in #{ingredient.name}"
        )
      end
    end
  end

  describe "callbacks" do
    let(:order_product) { build(:order_product, :with_order, product: product) }

    before { order_product.save }

    context "when parent product have a recipe_id add_recipe before_create" do
      let(:product) { create(:product, :with_recipe, trait_ingredient_recipe_amount: 2) }

      it "adds the recipe_id of the parent product" do
        expect(order_product.recipe_id).not_to be_nil
      end

      it "saves the order_product record" do
        expect(order_product).to be_persisted
      end
    end

    context "when parent product does not add_recipe before_create" do
      let(:product) { create(:product) }

      it "recipe_id is nil" do
        expect(order_product.recipe_id).to be_nil
      end

      it "saves the order_product record" do
        expect(order_product).to be_persisted
      end
    end
  end

  describe "status transitions" do
    describe "when prepare is executed with to_prepare" do
      before { order_product_object.status = 'to_prepare' }

      it do
        expect { order_product_object.prepare }.to change(
          order_product_object, :status).from("to_prepare").to("preparing")
      end
    end

    describe "when complete is executed with preparing" do
      before { order_product_object.status = 'preparing' }

      it do
        expect { order_product_object.complete }.to change(
          order_product_object, :status).from("preparing").to("completed")
      end
    end
  end
end
