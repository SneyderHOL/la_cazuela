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
    subject(:create_inventory_transactions_job) { described_class.perform_now(resource) }

    context "when enqueues the inventory transaction for creation" do
      before do
        ActiveJob::Base.queue_adapter = :test
      end

      it { expect { create_inventory_transactions_job }.to have_enqueued_job }
    end

    context "when CreateInventoryTransactionJob is called" do
      before do
        allow(CreateInventoryTransactionJob).to receive(:perform_later).with(transaction_param)
        create_inventory_transactions_job
      end

      it { expect(CreateInventoryTransactionJob).to have_received(:perform_later).once }
    end
  end
end
