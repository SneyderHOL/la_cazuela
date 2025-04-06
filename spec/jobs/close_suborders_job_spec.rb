require 'rails_helper'

RSpec.describe CloseSubordersJob, type: :job do
  let(:order) { create(:order, :as_completed, :with_allocation, :with_completed_suborders) }

  describe '#perform_later' do
    describe "enqueing a new job" do
      let(:resource) { order }

      it_behaves_like "job enqueued for resource"
    end
  end

  describe "#perform_now" do
    subject(:close_suborders_job) { described_class.perform_now(order) }

    context "when updates suborders status" do
      before do
        order.suborders.each { |suborder| suborder.update(status: "completed") }
        order.update(status: "closed")
        close_suborders_job
      end

      it "closes the child orders" do
        expect(order.suborders).to all(be_closed)
      end
    end

    context "when does not update suborders status" do
      before do
        order.suborders.each { |suborder| suborder.update(status: "completed") }
        close_suborders_job
      end

      it "keeps the completed status for child orders" do
        expect(order.suborders).to all(be_completed)
      end
    end
  end
end
