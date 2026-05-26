require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { build(:order, :with_sell_order) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'status is not nil' do
      expect(order.status).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:sell_order) }
    it { is_expected.to have_many(:products).through(:order_products) }
    it { is_expected.to have_many(:order_products) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "status transitions" do
    context "when process is executed and the order is opened and is persisted" do
      before do
        allow(ReadyToCookOrderProductsJob).to receive(:perform_later)
        order.save
      end

      it "change status" do
        expect { order.process }.to change(
          order, :status).from("opened").to("processing")
      end

      it do
        order.process
        expect(ReadyToCookOrderProductsJob).to have_received(:perform_later)
      end
    end

    context "when process is executed and the order is opened and is not persisted" do
      before do
        allow(ReadyToCookOrderProductsJob).to receive(:perform_later)
      end

      it "change status" do
        expect { order.process }.to change(
          order, :status).from("opened").to("processing")
      end

      it do
        order.process
        expect(ReadyToCookOrderProductsJob).not_to have_received(:perform_later)
      end
    end

    context "when pack is executed and the order is processing and sell_order has a desk allocation" do
      before do
        order.status = 'processing'
        order.save
      end

      it "change status" do
        expect { order.pack }.to change(
          order, :status).from("processing").to("packed")
      end
    end

    context "when pack is executed and the order is processing and sell_order has a delivery allocation" do
      before do
        order.status = 'processing'
        order.save
        order.sell_order.allocation.delivery!
      end

      it "change status" do
        expect { order.pack }.to change(
          order, :status).from("processing").to("packed")
      end
    end

    context "when complete is executed and the order is processing and is not persisted" do
      before do
        allow(CompleteOrderProductsJob).to receive(:perform_later)
        order.status = 'processing'
      end

      it "change status" do
        expect { order.complete }.to change(
          order, :status).from("processing").to("completed")
      end

      it do
        order.complete
        expect(CompleteOrderProductsJob).not_to have_received(:perform_later)
      end
    end

    context "when complete is executed and the order is processing and is persisted" do
      before do
        allow(CompleteOrderProductsJob).to receive(:perform_later)
        order.status = 'processing'
        order.save
      end

      it "change status" do
        expect { order.complete }.to change(
          order, :status).from("processing").to("completed")
      end

      it do
        order.complete
        expect(CompleteOrderProductsJob).to have_received(:perform_later)
      end
    end
  end

  describe "#before_destroy callback" do
    context "when the order does not have order_products associations and is opened" do
      before { order.save }

      it { expect { order.destroy }.to change(described_class, :count).by(-1) }
      it { expect { order.destroy }.not_to change(OrderProduct, :count) }
    end

    context "when the order does have order_products associations and is opened" do
      let(:order_with_order_products) do
        create(:order, :with_sell_order, :with_products, trait_amount: 2)
      end

      before { order_with_order_products }

      it { expect { order_with_order_products.destroy }.to change(described_class, :count).by(-1) }
      it { expect { order_with_order_products.destroy }.to change(OrderProduct, :count).by(-2) }
    end

    context "when the order is processing" do
      before do
        order.status = "processing"
        order.save
      end

      it { expect { order.destroy }.not_to change(described_class, :count) }
    end

    context "when the order is packed" do
      before do
        order.status = "packed"
        order.save
      end

      it { expect { order.destroy }.not_to change(described_class, :count) }
    end

    context "when the order is completed" do
      before do
        order.status = "completed"
        order.save
      end

      it { expect { order.destroy }.not_to change(described_class, :count) }
    end
  end
end
