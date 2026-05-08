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

    context "when sell_order is closed" do
      it "does create the SellOrders::CreateBill service" do
        expect(SellOrders::CreateBill).to have_received(:new).with(sell_order).once
      end

      it "calls the instance service" do
        expect(instance_service).to have_received(:call).once
      end
    end

    context "when sell_order is invoicing" do
      let(:sell_order) { create(:sell_order, :as_invoicing, :with_allocation) }

      it "does create the SellOrders::CreateBill service" do
        expect(SellOrders::CreateBill).to have_received(:new).with(sell_order).once
      end

      it "calls the instance service" do
        expect(instance_service).to have_received(:call).once
      end
    end

    context "when sell_order is opened" do
      let(:sell_order) { create(:sell_order, :with_allocation) }

      it "does not create the SellOrders::CreateBill service" do
        expect(SellOrders::CreateBill).not_to have_received(:new).with(sell_order)
      end
    end

    context "when sell_order is packed" do
      let(:sell_order) { create(:sell_order, :as_packed, :with_allocation) }

      it "does not create the SellOrders::CreateBill service" do
        expect(SellOrders::CreateBill).not_to have_received(:new).with(sell_order)
      end
    end

    context "when sell_order is delivering" do
      let(:sell_order) { create(:sell_order, :as_delivering, :with_allocation) }

      it "does not create the SellOrders::CreateBill service" do
        expect(SellOrders::CreateBill).not_to have_received(:new).with(sell_order)
      end
    end
  end
end
