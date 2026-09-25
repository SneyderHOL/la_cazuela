require 'rails_helper'

# == Schema Information
#
# Table name: inventory_transactions
# Database name: primary
#
#  id               :bigint           not null, primary key
#  by_admin         :boolean          default(FALSE), not null
#  cost             :integer          default(0), not null
#  direction        :string           not null
#  error_message    :string
#  quantity         :integer          not null
#  status           :string           not null
#  transaction_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  ingredient_id    :bigint           not null
#  order_product_id :bigint
#
# Indexes
#
#  index_inventory_transactions_on_ingredient_id     (ingredient_id)
#  index_inventory_transactions_on_order_product_id  (order_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (order_product_id => order_products.id)
#
RSpec.describe InventoryTransaction, type: :model do
  subject(:inventory_transaction) do
    build(:inventory_transaction, :as_pending, :with_ingredient)
  end

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'direction is not nil' do
      expect(inventory_transaction.direction).not_to be_nil
    end

    it 'transaction_type is not nil' do
      expect(inventory_transaction.transaction_type).not_to be_nil
    end

    it 'quantity is not nil' do
      expect(inventory_transaction.quantity).not_to be_nil
    end

    it 'cost is not nil' do
      expect(inventory_transaction.cost).not_to be_nil
    end

    it 'status is not nil' do
      expect(inventory_transaction.status).not_to be_nil
    end

    it 'ingredient is not nil' do
      expect(inventory_transaction.ingredient).not_to be_nil
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:direction) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:transaction_type) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:cost).is_greater_than_or_equal_to(0) }

    context "with purchase type and addition direction is valid" do
      before do
        inventory_transaction.transaction_type = :purchase
        inventory_transaction.direction = :addition
      end

      it { is_expected.to be_valid }
    end

    context "with purchase type and subtraction direction is invalid" do
      before do
        inventory_transaction.transaction_type = :purchase
        inventory_transaction.direction = :subtraction
      end

      it { is_expected.not_to be_valid }
    end

    context "with production type and addition direction is valid" do
      before do
        inventory_transaction.transaction_type = :production
        inventory_transaction.direction = :addition
      end

      it { is_expected.to be_valid }
    end

    context "with production type and subtraction direction is invalid" do
      before do
        inventory_transaction.transaction_type = :production
        inventory_transaction.direction = :subtraction
      end

      it { is_expected.not_to be_valid }
    end

    context "with production type and subtraction direction is valid" do
      before do
        inventory_transaction.transaction_type = :consumption
        inventory_transaction.direction = :subtraction
      end

      it { is_expected.to be_valid }
    end

    context "with production type and addition direction is invalid" do
      before do
        inventory_transaction.transaction_type = :consumption
        inventory_transaction.direction = :addition
      end

      it { is_expected.not_to be_valid }
    end

    context "with adjustment type and addition direction is valid" do
      before do
        inventory_transaction.transaction_type = :adjustment
        inventory_transaction.direction = :addition
      end

      it { is_expected.to be_valid }
    end

    context "with adjustment type and subtraction direction is valid" do
      before do
        inventory_transaction.transaction_type = :adjustment
        inventory_transaction.direction = :subtraction
      end

      it { is_expected.to be_valid }
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:ingredient) }
    it { is_expected.to belong_to(:order_product).optional }
  end

  describe "status transitions" do
    describe 'complete' do
      before { inventory_transaction.status = 'pending' }

      it do
        expect { inventory_transaction.complete }.to change(
          inventory_transaction, :status).from("pending").to("completed")
      end
    end
  end

  describe "#apply!" do
    let(:ingredient) { create(:ingredient, stored_quantity: 100, cost: 1_000) }

    context "when inventory_transaction is of type purchase, as addition and "\
            "ingredient is regular but completed" do
      let(:direction) { :addition }
      let(:transaction) do
        create(:inventory_transaction, :as_completed, ingredient:, direction:, quantity: 10, cost: 100)
      end

      it { expect { transaction.apply! }.to raise_error(InventoryTransaction::InvalidTransactionStatusError, "the transaction was already completed") }
    end

    context "when inventory_transaction is of type purchase, as addition and "\
            "ingredient is regular but associated with an order_product" do
      let(:direction) { :addition }
      let(:order_product) { create(:order_product, :with_associations) }
      let(:transaction) do
        create(:inventory_transaction, ingredient:, order_product:, direction:, quantity: 10, cost: 100)
      end

      it { expect { transaction.apply! }.to raise_error(InventoryTransaction::InvalidTransactionError, "order product can only be associated with consumption transactions") }
    end

    context "when inventory_transaction is of type production, as addition and "\
            "ingredient is regular but associated with an order_product" do
      let(:direction) { :addition }
      let(:order_product) { create(:order_product, :with_associations) }
      let(:transaction) do
        create(:inventory_transaction, :as_production_type, ingredient:, order_product:, direction:, quantity: 10, cost: 100)
      end

      it { expect { transaction.apply! }.to raise_error(InventoryTransaction::InvalidTransactionError, "order product can only be associated with consumption transactions") }
    end

    context "when inventory_transaction is of type adjustment, as addition and "\
            "ingredient is regular but associated with an order_product" do
      let(:direction) { :addition }
      let(:order_product) { create(:order_product, :with_associations) }
      let(:transaction) do
        create(:inventory_transaction, :as_adjustment_type, ingredient:, order_product:,
               direction:, quantity: 10, cost: 100)
      end

      it { expect { transaction.apply! }.to raise_error(InventoryTransaction::InvalidTransactionError, "order product can only be associated with consumption transactions") }
    end

    context "when inventory_transaction is of type adjustment, as subtraction and "\
            "ingredient is regular but associated with an order_product" do
      let(:direction) { :subtraction }
      let(:order_product) { create(:order_product, :with_associations) }
      let(:transaction) do
        create(:inventory_transaction, :as_adjustment_type, ingredient:, order_product:,
               direction:, quantity: 10, cost: 100)
      end

      it { expect { transaction.apply! }.to raise_error(InventoryTransaction::InvalidTransactionError, "order product can only be associated with consumption transactions") }
    end

    context "when inventory_transaction is of type consumption, as subtraction and "\
            "ingredient is regular but missing order_product" do
      let(:direction) { :subtraction }
      let(:order_product) { create(:order_product, :with_associations, quantity: 1) }
      let(:ingredient) do
        order_product.product.recipe.ingredient_recipes.first.ingredient
      end
      let(:transaction) do
        create(:inventory_transaction, :as_consumption_type, ingredient:, direction:,
               quantity: 10, cost: 100)
      end

      it { expect { transaction.apply! }.to raise_error(InventoryTransaction::InvalidTransactionError, "order product is required for consumption transactions") }
    end

    context "when inventory_transaction is of type purchase, as addition and "\
            "ingredient is regular" do
      let(:direction) { :addition }
      let(:transaction) do
        create(:inventory_transaction, ingredient:, direction:, quantity: 10, cost: 100)
      end

      before do
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(110) }
      it { expect(ingredient.cost).to be(1_100) }
      it { expect(transaction).to be_completed }
    end

    context "when inventory_transaction is of type purchase, as addition and ingredient "\
            "is base" do
      let(:direction) { :addition }
      let(:transaction) do
        create(:inventory_transaction, ingredient:, direction:, quantity: 10, cost: 100)
      end

      before do
        ingredient.update(ingredient_type: :base)
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(110) }
      it { expect(ingredient.cost).to be(1_100) }
      it { expect(transaction).to be_completed }
    end

    context "when inventory_transaction is of type adjustment, as addition and "\
            "ingredient is regular" do
      let(:direction) { :addition }
      let(:transaction) do
        create(:inventory_transaction, :as_adjustment_type, ingredient:, direction:, quantity: 10, cost: 100)
      end

      before do
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(110) }
      it { expect(ingredient.cost).to be(1_100) }
      it { expect(transaction).to be_completed }
    end

    context "when inventory_transaction is of type adjustment, as subtraction and "\
            "ingredient is regular" do
      let(:direction) { :subtraction }
      let(:transaction) do
        create(:inventory_transaction, :as_adjustment_type, ingredient:, direction:, quantity: 10, cost: 100)
      end

      before do
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(90) }
      it { expect(ingredient.cost).to be(900) }
      it { expect(transaction).to be_completed }
    end

    context "when inventory_transaction is of type consumption, as subtraction and "\
            "ingredient is regular" do
      let(:direction) { :subtraction }
      let(:order_product) { create(:order_product, :with_associations, quantity: 1) }
      let(:ingredient) do
        order_product.product.recipe.ingredient_recipes.first.ingredient
      end
      let(:transaction) do
        create(:inventory_transaction, :as_consumption_type, ingredient:, direction:,
               order_product:, quantity: 10, cost: 100)
      end

      before do
        ingredient.update(stored_quantity: 100, cost: 1_000)
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(90) }
      it { expect(ingredient.cost).to be(900) }
      it { expect(transaction).to be_completed }
    end

    context "when inventory_transaction is of type production, as addition and "\
            "ingredient is regular" do
      let(:direction) { :addition }
      let(:transaction) do
        create(:inventory_transaction, :as_production_type, ingredient:, direction:, quantity: 10, cost: 100)
      end

      it { expect { transaction.apply! }.to raise_error(InventoryTransaction::InvalidTransactionError, "production transactions require a base ingredient") }
    end

    context "when inventory_transaction is of type production, as addition and "\
            "ingredient is base but insufficient stock on the produce service" do
      let(:direction) { :addition }
      let(:transaction) do
        create(:inventory_transaction, :as_production_type, ingredient:, direction:, quantity: 10, cost: 100)
      end
      let(:production_service_instance) { instance_double(Inventory::ProduceBaseIngredient) }

      before do
        ingredient.update(ingredient_type: :base)
        allow(Inventory::ProduceBaseIngredient).to receive(:new).and_return(production_service_instance)
        allow(production_service_instance).to receive(:call) { raise Inventory::ProduceBaseIngredient::InsufficientStockError, "Salt has insufficient stock" }
      end

      it { expect { transaction.apply! }.to raise_error(InventoryTransaction::InsufficientStockError, "Insufficient stock. Error: Salt has insufficient stock") }

      # rubocop:disable RSpec/MultipleExpectations
      it "saves the error message when an exception is raised" do
        expect { transaction.apply! }.to raise_error(InventoryTransaction::InsufficientStockError, "Insufficient stock. Error: Salt has insufficient stock")
        expect(transaction.reload.error_message).to eq("Insufficient stock. Error: Salt has insufficient stock")
      end
      # rubocop:enable RSpec/MultipleExpectations
    end

    context "when inventory_transaction is of type production, as addition and "\
            "ingredient is base" do
      let(:direction) { :addition }
      let(:transaction) do
        create(:inventory_transaction, :as_production_type, ingredient:, direction:, quantity: 10, cost: 100)
      end
      let(:production_service_instance) { instance_double(Inventory::ProduceBaseIngredient) }

      before do
        ingredient.update(ingredient_type: :base)
        allow(Inventory::ProduceBaseIngredient).to receive(:new).and_return(production_service_instance)
        allow(production_service_instance).to receive_messages(call: true, production_cost: 1_000)
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(110) }
      it { expect(ingredient.cost).to be(2_000) }
      it { expect(transaction).to be_completed }
    end
  end
end
