require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { build(:order, :with_allocation) }

  let(:suborder) { create(:suborder, :with_associations) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'status is not nil' do
      expect(order.status).not_to be_nil
    end

    describe 'when order has parent order' do
      it 'is valid' do
        expect(suborder).to be_valid
      end

      it 'status is not nil' do
        expect(suborder.status).not_to be_nil
      end

      it 'parent_id is not nil' do
        expect(suborder.parent_id).not_to be_nil
      end

      it 'allocation_id is not nil' do
        expect(suborder.allocation_id).not_to be_nil
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:allocation) }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:suborders) }
    it { is_expected.to have_many(:products).through(:order_products) }
    it { is_expected.to have_many(:order_products) }
  end

  describe "validations" do
    let(:aux_suborder) { build(:order, :with_allocation) }

    it { is_expected.to validate_presence_of(:status) }

    describe "parent_assignation when parent_order is opened order is valid" do
      let(:parent_order) { create(:order, :with_allocation) }

      before { aux_suborder.parent = parent_order }

      it { expect(aux_suborder).to be_valid }
    end

    describe "parent_assignation when parent_order is processing order is valid" do
      let(:parent_order) { create(:order, :as_processing, :with_allocation) }

      before { aux_suborder.parent = parent_order }

      it { expect(aux_suborder).to be_valid }
    end

    describe "parent_assignation when parent_order is completed order is valid" do
      let(:parent_order) { create(:order, :as_completed, :with_allocation) }

      before { aux_suborder.parent = parent_order }

      it { expect(aux_suborder).to be_valid }
    end

    describe "parent_assignation parent_order is closed is not valid" do
      let(:parent_order) { create(:order, :as_closed, :with_allocation) }

      before { aux_suborder.parent = parent_order }

      it { expect(aux_suborder).not_to be_valid }
    end

    describe "parent_assignation when parent order is a suborder is not valid" do
      before { aux_suborder.parent = suborder }

      it { expect(aux_suborder).not_to be_valid }
    end

    describe "parent_assignation when parent order is a suborder and order is persisted is not valid" do
      before do
        aux_suborder.save
        aux_suborder.parent = suborder
      end

      it { expect(aux_suborder).not_to be_valid }
    end
  end

  describe "status transitions" do
    context "when process is executed and the order is opened and is persisted" do
      before do
        allow(PrepareOrderProductsJob).to receive(:perform_later)
        order.status = 'opened'
        order.save
      end

      it "change status" do
        expect { order.process }.to change(
          order, :status).from("opened").to("processing")
      end

      it do
        order.process
        expect(PrepareOrderProductsJob).to have_received(:perform_later)
      end
    end

    context "when process is executed and the order is opened and is not persisted" do
      before do
        allow(PrepareOrderProductsJob).to receive(:perform_later)
        order.status = 'opened'
      end

      it "change status" do
        expect { order.process }.to change(
          order, :status).from("opened").to("processing")
      end

      it do
        order.process
        expect(PrepareOrderProductsJob).not_to have_received(:perform_later)
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

    context "when deliver is executed and the order is processing and has a desk allocation" do
      before do
        order.status = 'processing'
        order.save
      end

      it "raise AASM::InvalidTransition error" do
        expect { order.deliver }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when deliver is executed and the order is processing and has a delivery allocation" do
      before do
        order.status = 'processing'
        order.save
        order.allocation.delivery!
      end

      it "change status" do
        expect { order.deliver }.to change(
          order, :status).from("processing").to("delivering")
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

    context "when close is executed and the order is processing and is not persisted" do
      before do
        allow(CloseSubordersJob).to receive(:perform_later)
        allow(CompleteOrderProductsJob).to receive(:perform_later)
        order.status = 'processing'
      end

      it "change status" do
        expect { order.close }.to change(
          order, :status).from("processing").to("closed")
      end

      it do
        order.close
        expect(CompleteOrderProductsJob).not_to have_received(:perform_later)
      end

      it do
        order.close
        expect(CloseSubordersJob).not_to have_received(:perform_later)
      end
    end

    context "when close is executed and the order is processing and is persisted" do
      before do
        allow(CloseSubordersJob).to receive(:perform_later)
        allow(CompleteOrderProductsJob).to receive(:perform_later)
        order.status = 'processing'
        order.save
      end

      it "change status" do
        expect { order.close }.to change(
          order, :status).from("processing").to("closed")
      end

      it do
        order.close
        expect(CompleteOrderProductsJob).to have_received(:perform_later)
      end

      it do
        order.close
        expect(CloseSubordersJob).to have_received(:perform_later)
      end
    end

    context "when close is executed and the order is completed and is not persisted" do
      before do
        allow(CloseSubordersJob).to receive(:perform_later)
        allow(CompleteOrderProductsJob).to receive(:perform_later)
        order.status = 'completed'
      end

      it "change status" do
        expect { order.close }.to change(
          order, :status).from("completed").to("closed")
      end

      it do
        order.close
        expect(CompleteOrderProductsJob).not_to have_received(:perform_later)
      end

      it do
        order.close
        expect(CloseSubordersJob).not_to have_received(:perform_later)
      end
    end

    context "when close is executed and the order is completed and is persisted" do
      before do
        allow(CloseSubordersJob).to receive(:perform_later)
        allow(CompleteOrderProductsJob).to receive(:perform_later)
        order.status = 'completed'
        order.save
      end

      it "change status" do
        expect { order.close }.to change(
          order, :status).from("completed").to("closed")
      end

      it do
        order.close
        expect(CompleteOrderProductsJob).to have_received(:perform_later)
      end

      it do
        order.close
        expect(CloseSubordersJob).to have_received(:perform_later)
      end
    end
  end
end
