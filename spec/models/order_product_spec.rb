require 'rails_helper'

RSpec.describe OrderProduct, type: :model do
  subject(:order_product) { build(:order_product, :with_associations) }

  describe "factory object" do
    it 'is valid' do
      expect(order_product).to be_valid
      expect(order_product.order).not_to be_nil
      expect(order_product.product).not_to be_nil
      expect(order_product.quantity).not_to be_nil
      expect(order_product.status).not_to be_nil
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
  end

  describe "callbacks" do
    describe "before_create" do
      let(:order_product) { create(:order_product, :with_order, product: product) }
      context "when parent product have a recipe_id" do
        let(:product) { create(:product, :with_recipe, trait_amount: 2) }
        it "adds the recipe_id of the parent product" do
          expect(product.recipe.id).not_to be_nil
          order_product.save
          expect(order_product.recipe_id).not_to be_nil
        end
      end

      context "when parent product does not have a recipe_id" do
        let(:product) { create(:product) }
        it "recipe_id is nil" do
          expect(product.recipe).to be_nil
          order_product.save
          expect(order_product.recipe_id).to be_nil
        end
      end
    end
  end

  describe "status transitions" do
    describe 'prepare' do
      before { order_product.status = 'to_prepare' }
      it do
        expect { order_product.prepare }.to change(
          order_product, :status).from("to_prepare").to("preparing")
      end
    end

    describe 'complete' do
      before { order_product.status = 'preparing' }
      it do
        expect { order_product.complete }.to change(
          order_product, :status).from("preparing").to("completed")
      end
    end
  end
end
