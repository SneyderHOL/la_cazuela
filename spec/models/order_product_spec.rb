require 'rails_helper'

# == Schema Information
#
# Table name: order_products
# Database name: primary
#
#  id          :bigint           not null, primary key
#  inventoried :boolean
#  note        :string
#  quantity    :integer          not null
#  status      :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  order_id    :bigint           not null
#  product_id  :bigint           not null
#  recipe_id   :bigint
#
# Indexes
#
#  index_order_products_on_order_id    (order_id)
#  index_order_products_on_product_id  (product_id)
#  index_order_products_on_recipe_id   (recipe_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (product_id => products.id)
#
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
    let(:recipe) { create(:recipe, :as_approved, product: create(:product, :with_category)) }
    let(:ingredient_recipe) do
      create(:ingredient_recipe, required_quantity: 11,
        ingredient: ingredient, recipe: recipe)
    end

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }

    describe "ingredient_availability on create when quantity is 1 is invalid" do
      let(:order_product) do
        build(:order_product, :with_order, product: recipe.product, quantity: 1)
      end
      let(:ingredient) { create(:ingredient, stored_quantity: 10) }

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

    describe "ingredient_availability on create when quantity is 1 is valid" do
      let(:order_product) do
        build(:order_product, :with_order, product: recipe.product, quantity: 2)
      end
      let(:ingredient) { create(:ingredient, stored_quantity: 22) }

      before do
        ingredient_recipe
        order_product.save
        ingredient.reload
      end

      it "does not updates the stored_quantity to the related ingredient" do
        expect(ingredient.stored_quantity).to be(22)
      end

      it "does not save the order product object" do
        expect(order_product).to be_persisted
      end

      it "is invalid" do
        expect(order_product).to be_valid
      end

      it "does not have errors" do
        expect(order_product.errors).to be_empty
      end
    end
  end

  describe "callbacks" do
    let(:order_product) { build(:order_product, :with_order, product: product) }

    before { order_product.save }

    context "when parent product have a recipe_id add_recipe before_create" do
      let(:product) { create(:product, :with_recipe, :with_category, trait_ingredient_recipe_amount: 2) }

      it "adds the recipe_id of the parent product" do
        expect(order_product.recipe_id).not_to be_nil
      end

      it "saves the order_product record" do
        expect(order_product).to be_persisted
      end
    end

    context "when parent product does not add_recipe before_create" do
      let(:product) { create(:product, :with_category) }

      it "recipe_id is nil" do
        expect(order_product.recipe_id).to be_nil
      end

      it "saves the order_product record" do
        expect(order_product).to be_persisted
      end
    end
  end

  describe "status transitions" do
    describe "when cook is executed with requested" do
      it "raises an error" do
        expect { order_product_object.cook }.to raise_error(
          AASM::InvalidTransition, "Event 'cook' cannot transition from 'requested'."
        )
      end
    end

    describe "when complete is executed with requested" do
      it "raises an error" do
        expect { order_product_object.complete }.to raise_error(
          AASM::InvalidTransition, "Event 'complete' cannot transition from 'requested'."
        )
      end
    end

    describe "when cook is executed with prepare" do
      before { order_product_object.status = 'prepare' }

      it do
        expect { order_product_object.cook }.to change(
          order_product_object, :status).from("prepare").to("preparing")
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

  describe "scopes" do
    context "with current_preparations" do
      include_context "with orders and order_products for scopes"

      it "retrieves the corresponding order_products" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.count).to eq(12)
        end
      end

      it "includes the corresponding order_products status" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.pluck(:status)).to include("requested", "prepare", "preparing", "completed")
        end
      end

      it "retrieves the corresponding order_products creation day" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.pluck(:created_at).map(&:day).uniq).to eq([ saturday.day ])
        end
      end

      it "retrieves the corresponding requested order_products" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.requested.count).to eq(2)
        end
      end

      it "includes the corresponding requested order_products status" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.requested.pluck(:status)).to include("requested")
        end
      end

      it "retrieves the corresponding prepare order_products" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.prepare.count).to eq(2)
        end
      end

      it "includes the corresponding prepare order_products status" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.prepare.pluck(:status)).to include("prepare")
        end
      end

      it "retrieves the corresponding preparing order_products" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.preparing.count).to eq(2)
        end
      end

      it "includes the corresponding preparing order_products status" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.preparing.pluck(:status)).to include("preparing")
        end
      end

      it "retrieves the corresponding completed order_products" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.completed.count).to eq(6)
        end
      end

      it "includes the corresponding completed order_products status" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations.completed.pluck(:status)).to include("completed")
        end
      end
    end

    context "with current_preparations_counting" do
      include_context "with orders and order_products for scopes"

      it "retrieves the corresponding order_products count" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations_counting).to eq({ "requested" => 2, "prepare" => 2, "preparing" => 2, "completed" => 6 })
        end
      end
    end

    context "with current_preparations_with_sell_orders" do
      let(:statuses) { %i[ requested prepare preparing ] }

      include_context "with orders and order_products for scopes"

      it "retrieves the corresponding order_products" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations_with_sell_orders(statuses).count).to eq(6)
        end
      end

      it "includes the corresponding order_products status" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(described_class.current_preparations_with_sell_orders(statuses).pluck(:status).uniq).to match_array(statuses.map(&:to_s))
        end
      end
    end
  end
end
