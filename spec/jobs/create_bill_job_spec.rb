require 'rails_helper'

RSpec.describe CreateBillJob, type: :job do
  let(:sell_order) { create(:sell_order, :as_closed, :with_allocation) }

  describe '#perform_later' do
    describe "enqueing a new job" do
      let(:resource) { sell_order }

      it_behaves_like "job enqueued for resource"
    end
  end

  describe "#perform_now" do
    subject(:create_bill_job) { described_class.perform_now(sell_order) }

    let(:instance_service) { instance_double(SellOrders::CreateBill) }

    before do
      allow(SellOrders::CreateBill).to receive(:new).with(sell_order).and_return(instance_service)
      allow(instance_service).to receive(:call)
      create_bill_job
    end

    it "does create the SellOrders::CreateBill service" do
      expect(SellOrders::CreateBill).to have_received(:new).with(sell_order).once
    end

    it "calls the instance service" do
      expect(instance_service).to have_received(:call).once
    end
  end
end
