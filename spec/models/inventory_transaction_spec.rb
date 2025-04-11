require 'rails_helper'

RSpec.describe InventoryTransaction, type: :model do
  subject(:inventory_transaction) do
    build(:inventory_transaction, :as_pending, :with_ingredient)
  end

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'kind is not nil' do
      expect(inventory_transaction.kind).not_to be_nil
    end

    it 'quantity is not nil' do
      expect(inventory_transaction.quantity).not_to be_nil
    end

    it 'status is not nil' do
      expect(inventory_transaction.status).not_to be_nil
    end

    it 'ingredient is not nil' do
      expect(inventory_transaction.ingredient).not_to be_nil
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }

    context "when status is set with a different value" do
      before { inventory_transaction.status = "bad" }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:ingredient) }
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
    let(:ingredient_stored_quantity) { 100 }
    let(:inventory_transaction_quantity) { 10 }
    let(:kind) { :addition }
    let(:ingredient) { create(:ingredient, stored_quantity: ingredient_stored_quantity) }
    let(:transaction) do
      create(:inventory_transaction, ingredient: ingredient,
        quantity: inventory_transaction_quantity, kind: kind)
    end

    before { allow(CreateInventoryTransactionsJob).to receive(:perform_later) }

    context "when inventory_transaction is of type addition and ingredient is regular" do
      before do
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(110) }
      it { expect(transaction).to be_completed }

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end

    context "when inventory_transaction is of type addition and ingredient is base" do
      let(:ingredient) do
        create(
          :ingredient,
          :with_base_type_and_recipe,
          stored_quantity: ingredient_stored_quantity,
          trait_ingredient_recipe_amount: 2
        )
      end

      before do
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(110) }
      it { expect(transaction).to be_completed }

      it_behaves_like "calls the CreateInventoryTransactionsJob"
    end

    context "when inventory_transaction is of type substraction and ingredient is regular" do
      let(:kind) { :substraction }

      before do
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(90) }
      it { expect(transaction).to be_completed }

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end

    context "when inventory_transaction is of type substraction and ingredient is base" do
      let(:ingredient) do
        create(
          :ingredient,
          :with_base_type_and_recipe,
          stored_quantity: ingredient_stored_quantity,
          trait_ingredient_recipe_amount: 2
        )
      end
      let(:kind) { :substraction }

      before do
        transaction.apply!
        ingredient.reload
      end

      it { expect(ingredient.stored_quantity).to be(90) }
      it { expect(transaction).to be_completed }

      it_behaves_like "calls the CreateInventoryTransactionsJob"
    end

    context "when inventory_transaction has status completed and ingredient is regular" do
      before { transaction.complete! }

      it "raises an error" do
        expect { transaction.apply! }.to raise_error(
          InventoryTransaction::InvalidTransactionStatusError, "the transaction was already completed"
        )
      end

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end

    context "when there is insufficient stock on associated ingredient" do
      before do
        allow(transaction.ingredient)
        .to receive(:update!) { raise ActiveRecord::RecordInvalid }
      end

      it "raises an error" do
        expect { transaction.apply! }.to raise_error(
          InventoryTransaction::InsufficientStockError, "Insufficient stock. Error: Record invalid"
        )
      end

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    # rubocop:disable RSpec/AnyInstance
    context "when there is insufficient stock if associated ingredient is a base ingredient" do
      let(:error_message) do
        "Validation failed: Stored quantity must be greater than or equal to 0 for "\
        "ingredient Sugar"
      end

      before do
        allow_any_instance_of(Ingredients::UpdateInventoryForBaseIngredients)
        .to receive(:call) { raise InventoryTransaction::InsufficientBaseStockError, error_message }
      end

      it "raises an error" do
        expect { transaction.apply! }.to raise_error(
          InventoryTransaction::InsufficientStockError, "Insufficient stock. Error: #{error_message}"
        )
      end

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end
    # rubocop:enable RSpec/AnyInstance
    # rubocop:enable RSpec/MultipleMemoizedHelpers

    context "when inventory_transaction has status completed and ingredient is base" do
      let(:ingredient) do
        create(
          :ingredient,
          :with_base_type_and_recipe,
          stored_quantity: ingredient_stored_quantity,
          trait_ingredient_recipe_amount: 2
        )
      end

      before { transaction.complete! }

      it "raises an error" do
        expect { transaction.apply! }.to raise_error(
          InventoryTransaction::InvalidTransactionStatusError, "the transaction was already completed"
        )
      end

      it_behaves_like "not call the CreateInventoryTransactionsJob"
    end
  end
end
