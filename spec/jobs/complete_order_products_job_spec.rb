require 'rails_helper'

RSpec.describe CompleteOrderProductsJob, type: :job do
  let(:order) { create(:order, :as_processing, :with_products, trait_amount: 2) }

  describe '#perform' do
    describe "enqueing a new job" do
      let(:resource) { order }
      it_behaves_like "job enqueued for resource"
    end

    describe "inline job execution" do
      subject { described_class.perform_now(order) }

      context "with a completed order" do
        before do
          order.update(status: "completed")
          order.order_products.each { |order_product| order_product.update(status: "preparing") }
          subject
        end

        context "when updates order_products status" do
          it "completes the order_products" do
            expect(order.order_products).to all(be_completed)
          end
        end
      end

      context "with a closed order" do
        before do
          order.update(status: "closed")
          order.order_products.each { |order_product| order_product.update(status: "preparing") }
          subject
        end
        context "when updates order_products status" do
          it "completes the order_products" do
            expect(order.order_products).to all(be_completed)
          end
        end
      end

      context "with a processing order" do
        context "when does not update order_products status" do
          before do
            order.order_products.each { |order_product| order_product.update(status: "preparing") }
            subject
          end
          it "keeps the initial status for order_products" do
            expect(order.order_products).to all(be_preparing)
          end
        end
      end
    end
  end
end
