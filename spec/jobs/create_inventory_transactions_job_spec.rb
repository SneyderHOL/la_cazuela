require 'rails_helper'

RSpec.describe CreateInventoryTransactionsJob, type: :job do
  let(:ingredient) { create(:ingredient) }
  let(:transaction_param) do
    { ingredient_id: ingredient.id, quantity: 2, kind: :substraction, status: "completed" }
  end
  let(:resource) { [ transaction_param ] }

  describe '#perform' do
    describe "enqueing a new job" do
      it_behaves_like "job enqueued for resource"
    end

    describe "inline job execution" do
      subject { described_class.perform_now(resource) }
      context "when creates the inventory transactions" do
        let(:inventory_transaction) { InventoryTransaction.first }
        it { expect { subject }.to change(InventoryTransaction, :count) }
        it do
          subject
          expect(inventory_transaction.ingredient).to eql(ingredient)
          expect(inventory_transaction.kind).to eql(transaction_param[:kind].to_s)
          expect(inventory_transaction.status).to eql(transaction_param[:status])
          expect(inventory_transaction.quantity).to eql(transaction_param[:quantity])
        end
      end
    end
  end
end
