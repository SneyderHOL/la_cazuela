require 'rails_helper'

RSpec.describe CompleteOrdersJob, type: :job do
  let(:sell_order) { create(:sell_order, :as_packed, :with_allocation, :with_packed_orders, :with_transfer_payment) }

  describe '#perform_later' do
    describe "enqueing a new job" do
      let(:resource) { sell_order }

      it_behaves_like "job enqueued for resource"
    end
  end

  describe "#perform_now" do
    subject(:complete_orders_job) { described_class.perform_now(sell_order.id) }

    context "when updates orders status to completed" do
      before do
        sell_order.orders.each { |order| order.update(status: "processing") }
        sell_order.update(status: "closed")
        complete_orders_job
        sell_order.reload
      end

      it "completes the related orders" do
        expect(sell_order.orders).to all(be_completed)
      end
    end

    context "when updates orders status to packed" do
      before do
        sell_order.allocation.update(kind: "delivery")
        sell_order.orders.each { |order| order.update(status: "processing") }
        sell_order.update(status: "closed")
        complete_orders_job
        sell_order.reload
      end

      it "keeps the packed status for child orders" do
        expect(sell_order.orders).to all(be_packed)
      end
    end

    context "when does not updates orders status" do
      before do
        sell_order.allocation.update(kind: "delivery")
        sell_order.orders.each { |order| order.update(status: "processing") }
        complete_orders_job
        sell_order.reload
      end

      it "keeps the packed status for child orders" do
        expect(sell_order.orders).to all(be_processing)
      end
    end
  end
end
