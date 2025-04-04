require 'rails_helper'

RSpec.describe InventoryTransaction, type: :model do
  subject(:inventory_transaction) do
    build(:inventory_transaction, :as_pending, :with_ingredient)
  end

  describe "factory object" do
    it 'is valid' do
      expect(inventory_transaction).to be_valid
      expect(inventory_transaction.kind).not_to be_nil
      expect(inventory_transaction.quantity).not_to be_nil
      expect(inventory_transaction.status).not_to be_nil
      expect(inventory_transaction.ingredient).not_to be_nil
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }

    context "when status is set with a different value" do
      before { subject.status = "bad" }
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
    let(:ingredient) do
      create(:ingredient, stored_quantity: ingredient_stored_quantity)
    end
    let(:transaction) do
      create(:inventory_transaction, ingredient: ingredient,
        quantity: inventory_transaction_quantity, kind: kind)
    end

    context "when inventory_transaction is of type addition" do
      before do
        transaction.apply!
        ingredient.reload
      end
      it { expect(ingredient.stored_quantity).to eql(110) }
      it { expect(transaction).to be_completed }
    end

    context "when inventory_transaction is of type substraction" do
      let(:kind) { :substraction }
      before do
        transaction.apply!
        ingredient.reload
      end
      it { expect(ingredient.stored_quantity).to eql(90) }
      it { expect(transaction).to be_completed }
    end

    context "when inventory_transaction has status completed" do
      before { transaction.complete! }
      it "should raise an error" do
        expect { transaction.apply! }.to raise_error(
          InventoryTransaction::InvalidTransactionStatusError, "the transaction was already completed"
        )
      end
    end
  end
end
