require 'rails_helper'

RSpec.describe Orders::CreateBill, type: :service do
  subject(:create_bill) { described_class.new(order) }

  describe '#call' do
    let(:product_one) { create(:product, :with_recipe, price: 15_000) }
    let(:product_two) { create(:product, :with_recipe, price: 10_000) }
    let(:product_three) { create(:product, :with_recipe, price: 5_000) }

    context "when order is a closed suborder" do
      let(:order) { create(:suborder, :with_associations, :as_closed) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does not call the create! method for Bill class" do
        expect(Bill).not_to have_received(:create!)
      end
    end

    context "when order is a completed suborder" do
      let(:order) { create(:suborder, :with_associations, :as_completed) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does not call the create! method for Bill class" do
        expect(Bill).not_to have_received(:create!)
      end
    end

    context "when order is a processing suborder" do
      let(:order) { create(:suborder, :with_associations, :as_processing) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does not call the create! method for Bill class" do
        expect(Bill).not_to have_received(:create!)
      end
    end

    context "when order is an opened suborder" do
      let(:order) { create(:suborder, :with_associations) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does not call the create! method for Bill class" do
        expect(Bill).not_to have_received(:create!)
      end
    end

    context "when order is an opened parent order" do
      let(:order) { create(:order, :with_allocation) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does not call the create! method for Bill class" do
        expect(Bill).not_to have_received(:create!)
      end
    end

    context "when order is an processing parent order" do
      let(:order) { create(:order, :with_allocation, :as_processing) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does not call the create! method for Bill class" do
        expect(Bill).not_to have_received(:create!)
      end
    end

    context "when order is a completed parent order" do
      let(:order) { create(:order, :with_allocation, :as_completed) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does not call the create! method for Bill class" do
        expect(Bill).not_to have_received(:create!)
      end
    end

    context "when order is a closed parent order without suborders" do
      let(:order) { create(:order, :with_allocation, :as_closed) }
      let(:expected_detail) do
        {
          product_one.name => { "quantity" => 5, "subtotal" => 75_000 },
          product_two.name => { "quantity" => 4, "subtotal" => 40_000 },
          product_three.name => { "quantity" => 3, "subtotal" => 15_000 }
        }
      end

      before do
        create(:order_product, order: order, product: product_one, quantity: 5)
        create(:order_product, order: order, product: product_two, quantity: 4)
        create(:order_product, order: order, product: product_three, quantity: 3)
      end

      it { expect { create_bill.call }.to change(Bill, :count).by(1) }

      it "create bill record with total" do
        create_bill.call
        expect(Bill.first.total).to be(130_000)
      end

      it "create bill record with detail" do
        create_bill.call
        expect(Bill.first.detail).to eql(expected_detail)
      end
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context "when order is a closed parent order with suborders" do
      let(:product_four) { create(:product, :with_recipe, price: 4_000) }
      let(:order) { create(:order, :with_allocation, :as_completed) }
      let(:suborder_one) { create(:suborder, :with_allocation, :as_completed, parent: order) }
      let(:suborder_two) { create(:suborder, :with_allocation, :as_completed, parent: order) }
      let(:suborder_three) { create(:suborder, :with_allocation, :as_completed, parent: order) }
      let(:expected_detail) do
        {
          product_one.name => { "quantity" => 6, "subtotal" => 90_000 },
          product_two.name => { "quantity" => 5, "subtotal" => 50_000 },
          product_three.name => { "quantity" => 8, "subtotal" => 40_000 },
          product_four.name => { "quantity" => 1, "subtotal" => 4_000 }
        }
      end

      before do
        create(:order_product, order: order, product: product_one, quantity: 5)
        create(:order_product, order: order, product: product_two, quantity: 4)
        create(:order_product, order: order, product: product_three, quantity: 3)
        create(:order_product, order: suborder_one, product: product_one, quantity: 1)
        create(:order_product, order: suborder_two, product: product_three, quantity: 5)
        create(:order_product, order: suborder_three, product: product_two, quantity: 1)
        create(:order_product, order: suborder_three, product: product_four, quantity: 1)
        order.update(status: "closed")
      end

      it { expect { create_bill.call }.to change(Bill, :count).by(1) }

      it "create bill record with total" do
        create_bill.call
        expect(Bill.first.total).to be(184_000)
      end

      it "create bill record with detail" do
        create_bill.call
        expect(Bill.first.detail).to eql(expected_detail)
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
