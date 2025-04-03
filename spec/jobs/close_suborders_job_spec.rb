require 'rails_helper'

RSpec.describe CloseSubordersJob, type: :job do
  let(:order) { create(:order, :as_completed, :with_suborders) }

  describe '#perform' do
    describe "enqueing a new job" do
      subject { described_class.perform_later(order) }

      before { ActiveJob::Base.queue_adapter = :test }

      it { expect { subject }.to have_enqueued_job }
    end

    describe "inline job execution" do
      subject { described_class.perform_now(order) }
      context "updates suborders status" do
        before do
          order.update(status: "closed")
          order.suborders.each { |suborder| suborder.update(status: "opened") }
          subject
        end
        it "closes the child orders" do
          expect(order.suborders).to all(be_closed)
        end
      end

      context "does not update suborders status" do
        before do
          order.suborders.each { |suborder| suborder.update(status: "opened") }
          subject
        end
        it "keeps the initial statues for child orders" do
          expect(order.suborders).to all(be_opened)
        end
      end
    end
  end
end
