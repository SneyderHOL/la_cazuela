require 'rails_helper'

# == Schema Information
#
# Table name: order_products
# Database name: primary
#
#  id                    :bigint           not null, primary key
#  inventory_consumed_at :datetime
#  note                  :string
#  quantity              :integer          not null
#  status                :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  order_id              :bigint           not null
#  product_id            :bigint           not null
#  recipe_id             :bigint
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
    it { is_expected.to have_many(:inventory_transactions).dependent(:restrict_with_error) }
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

      it "is valid" do
        expect(order_product).to be_valid
      end

      it "does not have errors" do
        expect(order_product.errors).to be_empty
      end
    end
  end

  describe "callbacks" do
    let(:order_product) { build(:order_product, :with_order, product: product) }

    context "when parent product have a recipe_id add_recipe before_create" do
      let(:product) { create(:product, :with_recipe, :with_category, trait_ingredient_recipe_amount: 2) }

      before { order_product.save }

      it "adds the recipe_id of the parent product" do
        expect(order_product.recipe_id).not_to be_nil
      end

      it "saves the order_product record" do
        expect(order_product).to be_persisted
      end
    end

    context "when parent product does not add_recipe before_create" do
      let(:product) { create(:product, :with_category) }

      before { order_product.save }

      it "recipe_id is nil" do
        expect(order_product.recipe_id).to be_nil
      end

      it "saves the order_product record" do
        expect(order_product).to be_persisted
      end
    end

    describe "validate_status_unless_parent_destroying when order_product is preparing" do
      before do
        order_product_object.status = :preparing
        order_product_object.save
        order_product_object.destroy
      end

      it "does not destroy the order product object" do
        expect(order_product_object).to be_persisted
      end

      it "has errors" do
        expect(order_product_object.errors).not_to be_empty
      end

      it "has error message" do
        expect(order_product_object.errors.full_messages).to include(
          "This record cannot be deleted because has already started or completed"
        )
      end
    end

    describe "validate_status_unless_parent_destroying when order_product is completed" do
      before do
        order_product_object.status = :completed
        order_product_object.save
        order_product_object.destroy
      end

      it "does not destroy the order product object" do
        expect(order_product_object).to be_persisted
      end

      it "has errors" do
        expect(order_product_object.errors).not_to be_empty
      end

      it "has error message" do
        expect(order_product_object.errors.full_messages).to include(
          "This record cannot be deleted because has already started or completed"
        )
      end
    end

    describe "validate_status_unless_parent_destroying when order_product is requested" do
      before do
        order_product_object.status = :requested
        order_product_object.save
        order_product_object.destroy
      end

      it "does destroy the order product object" do
        expect(order_product_object).to be_destroyed
      end
    end

    describe "validate_status_unless_parent_destroying when order_product is prepare" do
      before do
        order_product_object.status = :prepare
        order_product_object.save
        order_product_object.destroy
      end

      it "does destroy the order product object" do
        expect(order_product_object).to be_destroyed
      end
    end

    describe "validate_status_unless_parent_destroying when order_product is completed but marked for destruction" do
      before do
        order_product_object.status = :completed
        order_product_object.save
        order_product_object.order.update(order_products_attributes: [ id: order_product_object.id, _destroy: true ])
      end

      it "does destroy the order product object" do
        expect(described_class.where(id: order_product_object.id)).not_to exist
      end
    end
  end

  describe "status transitions" do
    let(:consumption_service_instance) { instance_double(Inventory::ConsumeOrderProduct) }

    describe "when ready_to_cook is executed with requested" do
      before { order_product_object.status = 'requested' }

      it do
        expect { order_product_object.ready_to_cook }.to change(
          order_product_object, :status).from("requested").to("prepare")
      end
    end

    describe "when ready_to_cook is executed with prepare" do
      before { order_product_object.status = 'prepare' }

      it "raise AASM::InvalidTransition error" do
        expect { order_product_object.ready_to_cook }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe "when ready_to_cook is executed with preparing" do
      before { order_product_object.status = 'preparing' }

      it "raise AASM::InvalidTransition error" do
        expect { order_product_object.ready_to_cook }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe "when ready_to_cook is executed with completed" do
      before { order_product_object.status = 'completed' }

      it "raise AASM::InvalidTransition error" do
        expect { order_product_object.ready_to_cook }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe "when cook is executed with prepare and success transition" do
      before do
        order_product_object.status = 'prepare'
        allow(Inventory::ConsumeOrderProduct).to receive(:new).and_return(consumption_service_instance)
        allow(consumption_service_instance).to receive(:call).and_return(true)
      end

      it do
        order_product_object.cook
        expect(Inventory::ConsumeOrderProduct).to have_received(:new).with(order_product_object).once
      end

      it do
        order_product_object.cook
        expect(consumption_service_instance).to have_received(:call)
      end

      it do
        expect { order_product_object.cook }.to change(
          order_product_object, :status).from("prepare").to("preparing")
      end
    end

    describe "when cook! is executed with prepare and success transition" do
      before do
        order_product_object.status = 'prepare'
        order_product_object.save
      end

      it "keeps no InventoryTransaction previously" do
        expect(InventoryTransaction.count).to eq(0)
      end

      it do
        expect { order_product_object.cook! }.to change(
          order_product_object, :status).from("prepare").to("preparing")
      end

      it "creates the InventoryTransactions after transition happens" do
        order_product_object.cook!
        expect(InventoryTransaction.count).to eq(5)
      end
    end

    describe "when cook is executed with prepare but when before hook failed due to insufficient stock" do
      before do
        order_product_object.status = 'requested'
        allow(Inventory::ConsumeOrderProduct).to receive(:new).and_return(consumption_service_instance)
        allow(consumption_service_instance).to receive(:call) { raise Inventory::ConsumeOrderProduct::InsufficientStockError }
      end

      it "raise Inventory::ConsumeOrderProduct::InsufficientStockError" do
        expect { order_product_object.cook }.to raise_error(Inventory::ConsumeOrderProduct::InsufficientStockError)
      end
    end

    describe "when cook is executed with prepare but when before hook failed due to already consumed" do
      before do
        order_product_object.status = 'requested'
        allow(Inventory::ConsumeOrderProduct).to receive(:new).and_return(consumption_service_instance)
        allow(consumption_service_instance).to receive(:call) { raise Inventory::ConsumeOrderProduct::AlreadyConsumedError }
      end

      it "raise Inventory::ConsumeOrderProduct::AlreadyConsumedError" do
        expect { order_product_object.cook }.to raise_error(Inventory::ConsumeOrderProduct::AlreadyConsumedError)
      end
    end

    describe "when cook is executed with prepare but when before hook failed due to missing recipe" do
      before do
        order_product_object.status = 'requested'
        allow(Inventory::ConsumeOrderProduct).to receive(:new).and_return(consumption_service_instance)
        allow(consumption_service_instance).to receive(:call) { raise Inventory::ConsumeOrderProduct::MissingRecipeError }
      end

      it "raise Inventory::ConsumeOrderProduct::MissingRecipeError" do
        expect { order_product_object.cook }.to raise_error(Inventory::ConsumeOrderProduct::MissingRecipeError)
      end
    end

    describe "when cook! is executed with requested status and rollback from state transition invalidation" do
      before do
        order_product_object.status = 'requested'
        order_product_object.save
      end

      it "keeps no InventoryTransaction" do
        expect(InventoryTransaction.count).to eq(0)
      end

      it "raise AASM::InvalidTransition error" do
        expect { order_product_object.cook! }.to raise_error(AASM::InvalidTransition)
      end

      # rubocop:disable RSpec/MultipleExpectations
      it "rolls back the InventoryTransaction when an AASM::InvalidTransition error is raised" do
        expect { order_product_object.cook! }.to raise_error(AASM::InvalidTransition)
        expect(InventoryTransaction.count).to eq(0)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end

    describe "when cook is executed with requested" do
      before do
        order_product_object.status = 'requested'
        allow(Inventory::ConsumeOrderProduct).to receive(:new).and_return(consumption_service_instance)
        allow(consumption_service_instance).to receive(:call).and_return(true)
      end

      it "raise AASM::InvalidTransition error" do
        expect { order_product_object.cook }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe "when cook is executed with preparing" do
      before do
        order_product_object.status = 'preparing'
        allow(Inventory::ConsumeOrderProduct).to receive(:new).and_return(consumption_service_instance)
        allow(consumption_service_instance).to receive(:call).and_return(true)
      end

      it "raise AASM::InvalidTransition error" do
        expect { order_product_object.cook }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe "when cook is executed with completed" do
      before do
        order_product_object.status = 'completed'
        allow(Inventory::ConsumeOrderProduct).to receive(:new).and_return(consumption_service_instance)
        allow(consumption_service_instance).to receive(:call).and_return(true)
      end

      it "raise AASM::InvalidTransition error" do
        expect { order_product_object.cook }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe "when complete is executed with prepare" do
      before do
        allow(OrderCompletionJob).to receive(:perform_later)
        order_product_object.status = 'prepare'
      end

      it do
        expect { order_product_object.complete }.to change(
          order_product_object, :status).from("prepare").to("completed")
      end

      it do
        order_product_object.complete
        expect(OrderCompletionJob).not_to have_received(:perform_later)
      end
    end

    describe "when complete is executed with preparing" do
      before do
        allow(OrderCompletionJob).to receive(:perform_later)
        order_product_object.status = 'preparing'
      end

      it do
        expect { order_product_object.complete }.to change(
          order_product_object, :status).from("preparing").to("completed")
      end

      it do
        order_product_object.complete
        expect(OrderCompletionJob).not_to have_received(:perform_later)
      end
    end

    describe "when complete is executed with requested" do
      before { order_product_object.status = 'requested' }

      it "raise AASM::InvalidTransition error" do
        expect { order_product_object.complete }.to raise_error(AASM::InvalidTransition)
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
