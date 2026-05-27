require 'rails_helper'

RSpec.describe SellOrders::CreateBill, type: :service do
  subject(:create_bill) { described_class.new(sell_order) }

  describe '#call' do
    let(:sell_order) { create(:sell_order, :with_allocation) }

    context "when sell_order is with an opened state" do
      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does not call the create! method for Bill class" do
        expect(Bill).not_to have_received(:create!)
      end
    end

    context "when sell_order is with a closed state and with an existing bill" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_closed, :with_bill) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does not call the create! method for Bill class" do
        expect(Bill).not_to have_received(:create!)
      end
    end

    context "when sell_order is with a packed state" do
      include_context "with sell_order soft composite"

      before do
        sell_order.update(status: "packed")
        allow(Bill).to receive(:create!).and_call_original
        create_bill.call
      end

      it "does call the create! method for Bill class" do
        expect(Bill).to have_received(:create!)
      end

      it "update sell_order record with expected total" do
        expect(sell_order.total).to be(75_000)
      end
    end

    context "when sell_order is with a delivering state" do
      include_context "with sell_order soft composite"

      before do
        sell_order.update(status: "delivering")
        allow(Bill).to receive(:create!).and_call_original
        create_bill.call
      end

      it "does call the create! method for Bill class" do
        expect(Bill).to have_received(:create!)
      end

      it "update sell_order record with expected total" do
        expect(sell_order.total).to be(75_000)
      end
    end

    context "when sell_order is with a closed state" do
      include_context "with sell_order soft composite"

      before do
        sell_order.update(status: "closed")
        allow(Bill).to receive(:create!).and_call_original
        create_bill.call
      end

      it "does call the create! method for Bill class" do
        expect(Bill).to have_received(:create!)
      end

      it "update sell_order record with expected total" do
        expect(sell_order.total).to be(75_000)
      end
    end

    context "when sell_order is with a closed status and no existing bills" do
      include_context "with sell_order composite"

      before do
        sell_order.update(status: "closed")
      end

      it { expect { create_bill.call }.to change(Bill, :count).by(1) }

      it "create bill record with expected total" do
        create_bill.call
        expect(Bill.first.total).to be(184_000)
      end

      it "create bill record with expected detail" do
        create_bill.call
        expect(Bill.first.detail).to eql(expected_detail)
      end

      it "update sell_order record with expected total" do
        create_bill.call
        expect(sell_order.total).to be(184_000)
      end
    end
  end
end
