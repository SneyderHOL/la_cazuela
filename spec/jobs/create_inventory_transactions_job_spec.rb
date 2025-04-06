require 'rails_helper'

RSpec.describe CreateInventoryTransactionsJob, type: :job do
  let(:ingredient) { create(:ingredient) }
  let(:transaction_param) do
    { ingredient_id: ingredient.id, quantity: 2, kind: :substraction, status: "completed" }
  end
  let(:resource) { [ transaction_param ] }

  describe '#perform_later' do
    describe "enqueing a new job" do
      it_behaves_like "job enqueued for resource"
    end
  end

  describe "#perform_now" do
    subject(:create_inventory_transaction_job) { described_class.perform_now(resource) }

    context "when creates the inventory transactions" do
      let(:inventory_transaction) { InventoryTransaction.first }

      it { expect { create_inventory_transaction_job }.to change(InventoryTransaction, :count) }

      it "create the record" do
        create_inventory_transaction_job
        expect(inventory_transaction.ingredient).to eql(ingredient)
      end

      it "match the kind param" do
        create_inventory_transaction_job
        expect(inventory_transaction.kind).to eql(transaction_param[:kind].to_s)
      end

      it "match the status param" do
        create_inventory_transaction_job
        expect(inventory_transaction.status).to eql(transaction_param[:status])
      end

      it "match the quantity param" do
        create_inventory_transaction_job
        expect(inventory_transaction.quantity).to eql(transaction_param[:quantity])
      end
    end
  end
end
