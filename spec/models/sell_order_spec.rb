require 'rails_helper'

RSpec.describe SellOrder, type: :model do
  subject(:sell_order) { build(:sell_order, :with_allocation) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it "status is not nil" do
      expect(sell_order.status).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:allocation) }
    it { is_expected.to have_many(:orders) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "status transitions" do
    context "when pack is executed with opened status" do
      before { sell_order.status = 'opened' }

      it do
        expect { sell_order.pack }.to change(
          sell_order, :status).from("opened").to("packed")
      end
    end

    context "when deliver is executed with packed status and has a delivery allocation" do
      before do
        sell_order.status = 'packed'
        sell_order.save
        sell_order.allocation.delivery!
      end

      it do
        expect { sell_order.deliver }.to change(
          sell_order, :status).from("packed").to("delivering")
      end
    end

    context "when deliver is executed with packed status and has a desk allocation" do
      before do
        sell_order.status = 'packed'
        sell_order.save
      end

      it "raise AASM::InvalidTransition error" do
        expect { sell_order.deliver }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when close is executed with opened status and is persisted" do
      before do
        allow(CompleteOrdersJob).to receive(:perform_later)
        allow(CreateBillJob).to receive(:perform_later)
        sell_order.save
      end

      it "change status" do
        expect { sell_order.close }.to change(
          sell_order, :status).from("opened").to("closed")
      end

      it do
        sell_order.close
        expect(CompleteOrdersJob).to have_received(:perform_later)
      end

      it do
        sell_order.close
        expect(CreateBillJob).to have_received(:perform_later)
      end
    end

    context "when close is executed with opened status and is not persisted" do
      before do
        allow(CompleteOrdersJob).to receive(:perform_later)
        allow(CreateBillJob).to receive(:perform_later)
      end

      it "change status" do
        expect { sell_order.close }.to change(
          sell_order, :status).from("opened").to("closed")
      end

      it do
        sell_order.close
        expect(CompleteOrdersJob).not_to have_received(:perform_later)
      end

      it do
        sell_order.close
        expect(CreateBillJob).not_to have_received(:perform_later)
      end
    end

    context "when close is executed with delivering status and is persisted" do
      before do
        allow(CompleteOrdersJob).to receive(:perform_later)
        allow(CreateBillJob).to receive(:perform_later)
        sell_order.status = 'delivering'
        sell_order.save
      end

      it "change status" do
        expect { sell_order.close }.to change(
          sell_order, :status).from("delivering").to("closed")
      end

      it do
        sell_order.close
        expect(CompleteOrdersJob).to have_received(:perform_later)
      end

      it do
        sell_order.close
        expect(CreateBillJob).to have_received(:perform_later)
      end
    end

    context "when close is executed with delivering status and is not persisted" do
      before do
        allow(CompleteOrdersJob).to receive(:perform_later)
        allow(CreateBillJob).to receive(:perform_later)
        sell_order.status = 'delivering'
      end

      it "change status" do
        expect { sell_order.close }.to change(
          sell_order, :status).from("delivering").to("closed")
      end

      it do
        sell_order.close
        expect(CompleteOrdersJob).not_to have_received(:perform_later)
      end

      it do
        sell_order.close
        expect(CreateBillJob).not_to have_received(:perform_later)
      end
    end
  end

  describe "#before_destroy callback" do
    context "when the sell_order does not have orders associations" do
      before { sell_order.save }

      it { expect { sell_order.destroy }.to change(described_class, :count).by(-1) }
      it { expect { sell_order.destroy }.not_to change(Order, :count) }
    end

    context "when the sell_order does have orders associations" do
      let(:sell_order_with_orders) do
        create(:sell_order, :with_associations)
      end

      before { sell_order_with_orders }

      it { expect { sell_order_with_orders.destroy }.not_to change(described_class, :count) }
      it { expect { sell_order_with_orders.destroy }.not_to change(Order, :count) }
    end
  end
end
