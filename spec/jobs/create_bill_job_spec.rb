require 'rails_helper'

RSpec.describe CreateBillJob, type: :job do
  let(:order) { create(:order, :as_closed, :with_allocation) }

  describe '#perform_later' do
    describe "enqueing a new job" do
      let(:resource) { order }

      it_behaves_like "job enqueued for resource"
    end
  end

  describe "#perform_now" do
    subject(:create_bill_job) { described_class.perform_now(order) }

    let(:instance_service) { instance_double(Orders::CreateBill) }

    before do
      allow(Orders::CreateBill).to receive(:new).with(order).and_return(instance_service)
      allow(instance_service).to receive(:call)
      create_bill_job
    end

    it "does create the Orders::CreateBill service" do
      expect(Orders::CreateBill).to have_received(:new).with(order).once
    end

    it "calls the instance service" do
      expect(instance_service).to have_received(:call).once
    end
  end
end
