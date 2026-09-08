require 'rails_helper'

RSpec.describe OrderCompletionJob, type: :job do
  let(:order) { create(:order, :with_sell_order, :with_products, trait_amount: 2) }

  describe '#perform_later' do
    describe "enqueing a new job" do
      let(:resource) { order }

      it_behaves_like "job enqueued for resource"
    end
  end

  describe "#perform_now" do
    subject(:order_completion_job) { described_class.perform_now(order) }

    context "when updates order status to complete from processing" do
      before do
        order.update(status: "processing")
        order.order_products.each { |order_product| order_product.update(status: "completed") }
        order_completion_job
      end

      it "completes the order" do
        expect(order).to be_completed
      end
    end

    context "when updates order status to packed from processing" do
      before do
        order.update(status: "processing")
        order.sell_order.allocation.update(kind: "delivery")
        order.order_products.each { |order_product| order_product.update(status: "completed") }
        order_completion_job
      end

      it "packs the order" do
        expect(order).to be_packed
      end
    end

    context "when does not updates order status to complete from opened with completed order_products" do
      before do
        order.order_products.each { |order_product| order_product.update(status: "completed") }
        order_completion_job
      end

      it "keeps the opened status" do
        expect(order).to be_opened
      end
    end

    context "when does not updates order status to complete from processing with some incompleted order_products" do
      before do
        order.update(status: "processing")
        order.order_products.first.update(status: "completed")
        order_completion_job
      end

      it "keeps the processing status" do
        expect(order).to be_processing
      end
    end

    context "when does not updates order status to complete from packed with completed order_products" do
      before do
        order.update(status: "packed")
        order.order_products.each { |order_product| order_product.update(status: "completed") }
        order_completion_job
      end

      it "keeps the packed status" do
        expect(order).to be_packed
      end
    end
  end
end
