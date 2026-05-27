require 'rails_helper'

RSpec.describe SellOrder, type: :model do
  subject(:sell_order) { build(:sell_order, :with_allocation) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it "status is not nil" do
      expect(sell_order.status).not_to be_nil
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:allocation) }
    it { is_expected.to have_many(:orders) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:total).is_greater_than(0).allow_nil }

    context "when the cash_pay validation is required" do
      before do
        sell_order.payment_type = :cash
        sell_order.total = 50_000
        sell_order.cash_pay = 100_000
      end

      it { is_expected.to validate_comparison_of(:cash_pay).is_greater_than_or_equal_to(:total) }
    end
  end

  describe "status transitions" do
    before do
      allow(CompleteOrdersJob).to receive(:perform_later)
      allow(CreateBillJob).to receive(:perform_later)
    end

    context "when invoice is executed with opened status" do
      before do
        sell_order.status = "opened"
        sell_order.save
      end

      it do
        expect { sell_order.invoice }.to change(
          sell_order, :status).from("opened").to("invoicing")
      end

      it do
        sell_order.invoice
        expect(CreateBillJob).to have_received(:perform_later)
      end
    end

    context "when invoice is executed with packed status" do
      before do
        sell_order.status = "packed"
        sell_order.save
      end

      it do
        expect { sell_order.invoice }.to change(
          sell_order, :status).from("packed").to("invoicing")
      end

      it do
        sell_order.invoice
        expect(CreateBillJob).to have_received(:perform_later)
      end
    end

    context "when invoice is executed with delivering status" do
      before do
        sell_order.status = "delivering"
        sell_order.save
      end

      it do
        expect { sell_order.invoice }.to change(
          sell_order, :status).from("delivering").to("invoicing")
      end

      it do
        sell_order.invoice
        expect(CreateBillJob).to have_received(:perform_later)
      end
    end

    context "when pack is executed with opened status" do
      before { sell_order.status = "opened" }

      it do
        expect { sell_order.pack }.to change(
          sell_order, :status).from("opened").to("packed")
      end
    end

    context "when deliver is executed with packed status and has a delivery allocation" do
      before do
        sell_order.status = "packed"
        sell_order.save
        sell_order.allocation.delivery!
      end

      it do
        expect { sell_order.deliver }.to change(
          sell_order, :status).from("packed").to("delivering")
      end
    end

    context "when deliver is executed with invoicing status and has a delivery allocation" do
      before do
        sell_order.status = "invoicing"
        sell_order.save
        sell_order.allocation.delivery!
      end

      it do
        expect { sell_order.deliver }.to change(
          sell_order, :status).from("invoicing").to("delivering")
      end
    end

    context "when deliver is executed with packed status and has a desk allocation" do
      before do
        sell_order.status = "packed"
        sell_order.save
      end

      it "raise AASM::InvalidTransition error" do
        expect { sell_order.deliver }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when close is executed with opened status and is persisted" do
      include_context "with sell_order close transition valid cash validation"

      before { sell_order.save }

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
      include_context "with sell_order close transition valid cash validation"

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
      include_context "with sell_order close transition valid cash validation"

      before do
        sell_order.status = "delivering"
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
      include_context "with sell_order close transition valid cash validation"

      before { sell_order.status = "delivering" }

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

    context "when close is executed with invoicing status, cash payment_type and is persisted" do
      include_context "with sell_order close transition valid cash validation"

      before do
        sell_order.status = "invoicing"
        sell_order.save
      end

      it "change status" do
        expect { sell_order.close }.to change(
          sell_order, :status).from("invoicing").to("closed")
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

    context "when close is executed with invoicing status, transfer payment_type and is persisted" do
      before do
        sell_order.payment_type = "transfer"
        sell_order.total = 20_000
        sell_order.status = "invoicing"
        sell_order.save
      end

      it "change status" do
        expect { sell_order.close }.to change(
          sell_order, :status).from("invoicing").to("closed")
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

    context "when close is executed with invoicing status, card payment_type and is persisted" do
      before do
        sell_order.payment_type = "card"
        sell_order.total = 20_000
        sell_order.status = "invoicing"
        sell_order.save
      end

      it "change status" do
        expect { sell_order.close }.to change(
          sell_order, :status).from("invoicing").to("closed")
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

    context "when close is executed with invoicing status and is not persisted" do
      include_context "with sell_order close transition valid cash validation"

      before { sell_order.status = "invoicing" }

      it "change status" do
        expect { sell_order.close }.to change(
          sell_order, :status).from("invoicing").to("closed")
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

    context "when close is executed with invoicing status and is not enable to close with card payment_type" do
      before do
        sell_order.payment_type = "card"
        sell_order.status = "invoicing"
        sell_order.save
      end

      it "raise AASM::InvalidTransition error" do
        expect { sell_order.close }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when close is executed with invoicing status and is not enable to close with transfer payment_type" do
      before do
        sell_order.payment_type = "transfer"
        sell_order.status = "invoicing"
        sell_order.save
      end

      it "raise AASM::InvalidTransition error" do
        expect { sell_order.close }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when close is executed with invoicing status and is not enable to close with cash payment_type" do
      before do
        sell_order.payment_type = "cash"
        sell_order.status = "invoicing"
        sell_order.save
      end

      it "raise AASM::InvalidTransition error" do
        expect { sell_order.close }.to raise_error(AASM::InvalidTransition)
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

  describe "#calculate_cash_change" do
    context "when sell_order does not have an invoicing status" do
      let(:sell_order) { create(:sell_order, :with_associations) }

      it { expect { sell_order.calculate_cash_change }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order does not have a bill associated" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing) }

      it { expect { sell_order.calculate_cash_change }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order does not have a cash payment_type" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing, :with_bill) }

      it { expect { sell_order.calculate_cash_change }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order does not have a total value" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing, :with_cash, :with_bill) }

      it { expect { sell_order.calculate_cash_change }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order does not have a cash_pay value" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing, :with_cash, :with_bill) }

      before { sell_order.update(total: sell_order.bill.total) }

      it { expect { sell_order.calculate_cash_change }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order is able to calculate cash_change value" do
      let(:total) { 75_000 }
      let(:cash_pay) { 100_000 }
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing, :with_cash, :with_bill, total:, cash_pay:) }

      it { expect { sell_order.calculate_cash_change }.to change(sell_order, :cash_change) }

      it "match the correct cash_change value" do
        sell_order.calculate_cash_change
        expect(sell_order.cash_change).to eq(25_000)
      end
    end
  end
end
