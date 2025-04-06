require 'rails_helper'

RSpec.describe CompleteOrderProductsJob, type: :job do
  let(:order) { create(:order, :as_processing, :with_allocation, :with_products, trait_amount: 2) }

  describe '#perform_later' do
    describe "enqueing a new job" do
      let(:resource) { order }

      it_behaves_like "job enqueued for resource"
    end
  end

  describe "#perform_now" do
    subject(:complete_order_product_job) { described_class.perform_now(order) }

    context "when updates order_products status with a completed order" do
      before do
        order.update(status: "completed")
        order.order_products.each { |order_product| order_product.update(status: "preparing") }
        complete_order_product_job
      end

      it "completes the order_products" do
        expect(order.order_products).to all(be_completed)
      end
    end

    context "when updates order_products status with a closed order" do
      before do
        order.update(status: "closed")
        order.order_products.each { |order_product| order_product.update(status: "preparing") }
        complete_order_product_job
      end

      it "completes the order_products" do
        expect(order.order_products).to all(be_completed)
      end
    end

    context "when does not update order_products status with a processing order" do
      before do
        order.order_products.each { |order_product| order_product.update(status: "preparing") }
        complete_order_product_job
      end

      it "keeps the initial status for order_products" do
        expect(order.order_products).to all(be_preparing)
      end
    end
  end
end
