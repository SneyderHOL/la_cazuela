require 'rails_helper'

RSpec.describe CompleteOrdersJob, type: :job do
  let(:sell_order) { create(:sell_order, :as_packed, :with_allocation, :with_packed_orders) }

  describe '#perform_later' do
    describe "enqueing a new job" do
      let(:resource) { sell_order }

      it_behaves_like "job enqueued for resource"
    end
  end

  describe "#perform_now" do
    subject(:complete_orders_job) { described_class.perform_now(sell_order) }

    context "when updates orders status" do
      before do
        sell_order.orders.each { |order| order.update(status: "packed") }
        sell_order.update(status: "closed")
        complete_orders_job
      end

      it "completes the related orders" do
        expect(sell_order.orders).to all(be_completed)
      end
    end

    context "when does not update orders status" do
      before do
        sell_order.orders.each { |order| order.update(status: "packed") }
        complete_orders_job
      end

      it "keeps the packed status for child orders" do
        expect(sell_order.orders).to all(be_packed)
      end
    end
  end
end
