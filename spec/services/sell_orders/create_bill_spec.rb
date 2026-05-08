require 'rails_helper'

RSpec.describe SellOrders::CreateBill, type: :service do
  subject(:create_bill) { described_class.new(sell_order) }

  describe '#call' do
    let(:product_one) { create(:product, :with_recipe, price: 15_000) }
    let(:product_two) { create(:product, :with_recipe, price: 10_000) }
    let(:product_three) { create(:product, :with_recipe, price: 5_000) }

    context "when sell_order is with an opened state" do
      let(:sell_order) { create(:sell_order, :with_associations) }

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

    context "when sell_order is with an packed state" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_packed) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does call the create! method for Bill class" do
        expect(Bill).to have_received(:create!)
      end
    end

    context "when sell_order is with a delivering state" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_delivering) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does call the create! method for Bill class" do
        expect(Bill).to have_received(:create!)
      end
    end

    context "when sell_order is with a closed state" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_closed) }

      before do
        allow(Bill).to receive(:create!)
        create_bill.call
      end

      it "does call the create! method for Bill class" do
        expect(Bill).to have_received(:create!)
      end
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context "when sell_order is with a closed status and no existing bills" do
      let(:product_four) { create(:product, :with_recipe, price: 4_000) }
      let(:sell_order) { create(:sell_order, :with_allocation) }
      let(:order_one) { create(:order, :as_completed, sell_order: sell_order) }
      let(:order_two) { create(:order, :as_completed, sell_order: sell_order) }
      let(:order_three) { create(:order, :as_completed, sell_order: sell_order) }
      let(:expected_detail) do
        {
          product_one.name => { "quantity" => 6, "subtotal" => 90_000 },
          product_two.name => { "quantity" => 5, "subtotal" => 50_000 },
          product_three.name => { "quantity" => 8, "subtotal" => 40_000 },
          product_four.name => { "quantity" => 1, "subtotal" => 4_000 }
        }
      end

      before do
        create(:order_product, order: order_one, product: product_one, quantity: 5)
        create(:order_product, order: order_one, product: product_two, quantity: 4)
        create(:order_product, order: order_two, product: product_three, quantity: 3)
        create(:order_product, order: order_two, product: product_one, quantity: 1)
        create(:order_product, order: order_two, product: product_three, quantity: 5)
        create(:order_product, order: order_three, product: product_two, quantity: 1)
        create(:order_product, order: order_three, product: product_four, quantity: 1)
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
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
