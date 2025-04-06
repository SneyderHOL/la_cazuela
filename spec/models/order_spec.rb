require 'rails_helper'

RSpec.shared_examples "when suborder is assigned a valid parent" do
  before { aux_suborder.parent = parent_order }
  it { expect(aux_suborder).to be_valid }
end

RSpec.shared_examples "calls the CloseSubordersJob" do
  it { expect(CloseSubordersJob).to have_received(:perform_later) }
end

RSpec.shared_examples "not call the CloseSubordersJob" do
  it { expect(CloseSubordersJob).not_to have_received(:perform_later) }
end

RSpec.shared_examples "calls the CompleteOrderProductsJob" do
  it { expect(CompleteOrderProductsJob).to have_received(:perform_later) }
end

RSpec.shared_examples "not call the CompleteOrderProductsJob" do
  it { expect(CompleteOrderProductsJob).not_to have_received(:perform_later) }
end

RSpec.shared_examples "calls the PrepareOrderProductsJob" do
  it { expect(PrepareOrderProductsJob).to have_received(:perform_later) }
end

RSpec.shared_examples "not call the PrepareOrderProductsJob" do
  it { expect(PrepareOrderProductsJob).not_to have_received(:perform_later) }
end

RSpec.describe Order, type: :model do
  subject(:order) { build(:order, :with_allocation) }
  let(:suborder) { create(:suborder, :with_associations) }

  describe "factory object" do
    it 'is valid' do
      expect(order).to be_valid
      expect(order.status).not_to be_nil
    end

    describe 'when order has parent order' do
      it do
        expect(suborder).to be_valid
        expect(suborder.status).not_to be_nil
        expect(suborder.parent_id).not_to be_nil
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
    it { is_expected.to validate_presence_of(:status) }

    describe "parent_assignation" do
      let(:parent_order) { create(:order, :with_allocation) }
      let(:aux_suborder) { build(:order, :with_allocation) }

      context "when is valid" do
        context "when parent_order is opened" do
          it_behaves_like "when suborder is assigned a valid parent"
        end

        context "when parent_order is processing" do
          let(:parent_order) { create(:order, :as_processing, :with_allocation) }
          it_behaves_like "when suborder is assigned a valid parent"
        end

        context "when parent_order is completed" do
          let(:parent_order) { create(:order, :as_completed, :with_allocation) }
          it_behaves_like "when suborder is assigned a valid parent"
        end
      end

      context "when is invalid" do
        context "with new child order" do
          context "when parent order is a suborder" do
            before { aux_suborder.parent = suborder }
            it { expect(aux_suborder).not_to be_valid }
          end
        end

        context "with persisted child order" do
          context "when parent order is a suborder" do
            before do
              aux_suborder.save
              aux_suborder.parent = suborder
            end
            it { expect(aux_suborder).not_to be_valid }
          end
        end

        context "when parent_order is closed" do
          let(:parent_order) { create(:order, :as_closed, :with_allocation) }
          before { aux_suborder.parent = parent_order }
          it { expect(aux_suborder).not_to be_valid }
        end
      end
    end
  end

  describe "status transitions" do
    describe 'process' do
      before do
        allow(PrepareOrderProductsJob).to receive(:perform_later)
        order.status = 'opened'
      end
      it do
        expect { order.process }.to change(
          order, :status).from("opened").to("processing")
      end
      context "when the order is persisted" do
        before do
          order.save
          order.process
        end
        it_behaves_like "calls the PrepareOrderProductsJob"
      end

      context "when the order is not persisted" do
        before { order.process }
        it_behaves_like "not call the PrepareOrderProductsJob"
      end
    end

    describe 'complete' do
      before do
        allow(CompleteOrderProductsJob).to receive(:perform_later)
        order.status = 'processing'
      end
      it do
        expect { order.complete }.to change(
          order, :status).from("processing").to("completed")
      end
      context "when the order is persisted" do
        before do
          order.save
          order.complete
        end
        it_behaves_like "calls the CompleteOrderProductsJob"
      end

      context "when the order is not persisted" do
        before { order.complete }
        it_behaves_like "not call the CompleteOrderProductsJob"
      end
    end

    describe 'close' do
      before do
        allow(CloseSubordersJob).to receive(:perform_later)
        allow(CompleteOrderProductsJob).to receive(:perform_later)
      end

      context "from opened to closed" do
        before { order.status = 'opened' }
        it do
          expect { order.close }.to change(
            order, :status).from("opened").to("closed")
        end
      end

      context "from processing to closed" do
        before { order.status = 'processing' }
        it do
          expect { order.close }.to change(
            order, :status).from("processing").to("closed")
        end
      end

      context "from completed to closed" do
        before { order.status = 'completed' }
        it do
          expect { order.close }.to change(
            order, :status).from("completed").to("closed")
        end
      end

      context "when the order is persisted" do
        before do
          order.save
          order.close
        end
        it_behaves_like "calls the CloseSubordersJob"
      end

      context "when the order is persisted and has a parent order" do
        before { suborder.close }
        it_behaves_like "not call the CloseSubordersJob"
        it_behaves_like "calls the CompleteOrderProductsJob"
      end

      context "when the order is not persisted" do
        before { order.close }
        it_behaves_like "not call the CloseSubordersJob"
        it_behaves_like "not call the CompleteOrderProductsJob"
      end
    end
  end
end
