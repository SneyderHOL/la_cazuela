require 'rails_helper'

# == Schema Information
#
# Table name: sell_orders
# Database name: primary
#
#  id            :bigint           not null, primary key
#  cash_change   :integer
#  cash_pay      :integer
#  payment_type  :string
#  status        :string           not null
#  total         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  allocation_id :bigint           not null
#
# Indexes
#
#  index_sell_orders_on_allocation_id  (allocation_id)
#
# Foreign Keys
#
#  fk_rails_...  (allocation_id => allocations.id)
#
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

    context "when the cash_pay presence validation is required" do
      before do
        sell_order.payment_type = :cash
        sell_order.total = 50_000
      end

      it { is_expected.to validate_presence_of(:cash_pay) }
    end

    context "when the cash_pay comparison validation is required" do
      before do
        sell_order.payment_type = :cash
        sell_order.total = 50_000
        sell_order.cash_pay = 100_000
      end

      it { is_expected.to validate_comparison_of(:cash_pay).is_greater_than_or_equal_to(:total) }
    end
  end

  describe "scopes" do
    context "with sales_by_date" do
      include_context "with sell_orders for scopes"

      # SUM is only performed on invoicing and closed sell_orders since the total value should bes

      it "retrieves the corresponding sell_orders from thursday" do
        expect(described_class.sales_by_date(thursday.to_date).count).to eq(15)
      end

      it "retrieves the corresponding opened sell_orders from thursday" do
        expect(described_class.sales_by_date(thursday.to_date).opened.count).to eq(3)
      end

      it "retrieves the corresponding packed sell_orders from thursday" do
        expect(described_class.sales_by_date(thursday.to_date).packed.count).to eq(3)
      end

      it "retrieves the corresponding invoicing sell_orders from thursday" do
        expect(described_class.sales_by_date(thursday.to_date).invoicing.count).to eq(3)
      end

      it "retrieves the corresponding delivering sell_orders from thursday" do
        expect(described_class.sales_by_date(thursday.to_date).delivering.count).to eq(3)
      end

      it "retrieves the corresponding closed sell_orders from thursday" do
        expect(described_class.sales_by_date(thursday.to_date).closed.count).to eq(3)
      end

      it "retrieves the corresponding total for invoicing sell_orders from thursday" do
        expect(described_class.sales_by_date(thursday.to_date).invoicing.sum(&:total)).to eq(2_400)
      end

      it "retrieves the corresponding total for delivering sell_orders from thursday" do
        expect(described_class.sales_by_date(thursday.to_date).delivering.sum(&:total)).to eq(3_300)
      end

      it "retrieves the corresponding total for closed sell_orders from thursday" do
        expect(described_class.sales_by_date(thursday.to_date).closed.sum(&:total)).to eq(4_200)
      end

      it "retrieves the corresponding sell_orders from friday" do
        expect(described_class.sales_by_date(friday.to_date).count).to eq(15)
      end

      it "retrieves the corresponding opened sell_orders from friday" do
        expect(described_class.sales_by_date(friday.to_date).opened.count).to eq(3)
      end

      it "retrieves the corresponding packed sell_orders from friday" do
        expect(described_class.sales_by_date(friday.to_date).packed.count).to eq(3)
      end

      it "retrieves the corresponding invoicing sell_orders from friday" do
        expect(described_class.sales_by_date(friday.to_date).invoicing.count).to eq(3)
      end

      it "retrieves the corresponding delivering sell_orders from friday" do
        expect(described_class.sales_by_date(friday.to_date).delivering.count).to eq(3)
      end

      it "retrieves the corresponding closed sell_orders from friday" do
        expect(described_class.sales_by_date(friday.to_date).closed.count).to eq(3)
      end

      it "retrieves the corresponding total for invoicing sell_orders from friday" do
        expect(described_class.sales_by_date(friday.to_date).invoicing.sum(&:total)).to eq(24_000)
      end

      it "retrieves the corresponding total for delivering sell_orders from friday" do
        expect(described_class.sales_by_date(friday.to_date).delivering.sum(&:total)).to eq(33_000)
      end

      it "retrieves the corresponding total for closed sell_orders from friday" do
        expect(described_class.sales_by_date(friday.to_date).closed.sum(&:total)).to eq(42_000)
      end

      it "retrieves the corresponding sell_orders from saturday" do
        expect(described_class.sales_by_date(saturday.to_date).count).to eq(15)
      end

      it "retrieves the corresponding opened sell_orders from saturday" do
        expect(described_class.sales_by_date(saturday.to_date).opened.count).to eq(3)
      end

      it "retrieves the corresponding packed sell_orders from saturday" do
        expect(described_class.sales_by_date(saturday.to_date).packed.count).to eq(3)
      end

      it "retrieves the corresponding invoicing sell_orders from saturday" do
        expect(described_class.sales_by_date(saturday.to_date).invoicing.count).to eq(3)
      end

      it "retrieves the corresponding closed sell_orders from saturday" do
        expect(described_class.sales_by_date(saturday.to_date).closed.count).to eq(3)
      end

      it "retrieves the corresponding total for invoicing sell_orders from saturday" do
        expect(described_class.sales_by_date(saturday.to_date).invoicing.sum(&:total)).to eq(240_000)
      end

      it "retrieves the corresponding total for delivering sell_orders from saturday" do
        expect(described_class.sales_by_date(saturday.to_date).delivering.sum(&:total)).to eq(330_000)
      end

      it "retrieves the corresponding total for closed sell_orders from saturday" do
        expect(described_class.sales_by_date(saturday.to_date).closed.sum(&:total)).to eq(420_000)
      end
    end

    # rubocop:disable RSpec/NestedGroups
    context "with current_sales" do
      include_context "with sell_orders for scopes"

      let(:kinds) { %i[ desk delivery takeout ] }
      let(:statuses) { %i[ opened packed invoicing delivering closed ] }

      context "with every status and every allocation kind" do
        it "retrieves the corresponding sell_orders" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kinds).count).to eq(15)
          end
        end

        it "retrieves the corresponding sell_orders status" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kinds).pluck(:status).uniq).to match_array(statuses.map(&:to_s))
          end
        end

        it "retrieves the corresponding sell_orders creation day" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kinds).pluck(:created_at).map(&:day).uniq).to eq([ saturday.day ])
          end
        end
      end

      context "with opened status and every allocation kind" do
        let(:status) { :opened }

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with packed status and every allocation kind" do
        let(:status) { :packed }

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with invoicing status and every allocation kind" do
        let(:status) { :invoicing }

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with delivering status and every allocation kind" do
        let(:status) { :delivering }

        # it { byebug }
        it_behaves_like "current_sales result for sell_orders"
      end

      context "with closed status and every allocation kind" do
        let(:status) { :closed }

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with every status and desk allocation kind" do
        let(:kind) { :desk }

        it "retrieves the corresponding sell_orders" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kind).count).to eq(12)
          end
        end

        it "retrieves the corresponding sell_orders status" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kind).pluck(:status).uniq).to contain_exactly("opened", "packed", "invoicing", "closed")
          end
        end

        it "retrieves the corresponding sell_orders creation day" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kind).pluck(:created_at).map(&:day).uniq).to eq([ saturday.day ])
          end
        end
      end

      context "with every status and delivery allocation kind" do
        let(:kind) { :delivery }

        before do
          described_class.all.each do |sell_order|
            sell_order.allocation.update(kind: :delivery)
          end
        end

        it "retrieves the corresponding sell_orders" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kind).count).to eq(15)
          end
        end

        it "retrieves the corresponding sell_orders status" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kind).pluck(:status).uniq).to contain_exactly("opened", "packed", "invoicing", "delivering", "closed")
          end
        end

        it "retrieves the corresponding sell_orders creation day" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kind).pluck(:created_at).map(&:day).uniq).to eq([ saturday.day ])
          end
        end
      end

      context "with every status and takeout allocation kind" do
        let(:kind) { :takeout }

        before do
          described_class.all.each do |sell_order|
            sell_order.allocation.update(kind: :takeout)
          end
          described_class.delivering.each do |sell_order|
            sell_order.allocation.update(kind: :delivery)
          end
        end

        it "retrieves the corresponding sell_orders" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kind).count).to eq(12)
          end
        end

        it "retrieves the corresponding sell_orders status" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kind).pluck(:status).uniq).to contain_exactly("opened", "packed", "invoicing", "closed")
          end
        end

        it "retrieves the corresponding sell_orders creation day" do
          specific_date = saturday + 3.hours

          travel_to specific_date do
            expect(described_class.current_sales(statuses, kind).pluck(:created_at).map(&:day).uniq).to eq([ saturday.day ])
          end
        end
      end

      context "with opened status and desk allocation kind" do
        let(:status) { :opened }
        let(:kinds) { :desk }

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with opened status and delivery allocation kind" do
        let(:status) { :opened }
        let(:kinds) { :delivery }

        before do
          described_class.opened.each do |sell_order|
            sell_order.allocation.update(kind: :delivery)
          end
        end

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with opened status and takeout allocation kind" do
        let(:status) { :opened }
        let(:kinds) { :takeout }

        before do
          described_class.opened.each do |sell_order|
            sell_order.allocation.update(kind: :takeout)
          end
        end

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with packed status and desk allocation kind" do
        let(:status) { :packed }
        let(:kinds) { :desk }

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with packed status and delivery allocation kind" do
        let(:status) { :packed }
        let(:kinds) { :delivery }

        before do
          described_class.packed.each do |sell_order|
            sell_order.allocation.update(kind: :delivery)
          end
        end

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with packed status and takeout allocation kind" do
        let(:status) { :packed }
        let(:kinds) { :takeout }

        before do
          described_class.packed.each do |sell_order|
            sell_order.allocation.update(kind: :takeout)
          end
        end

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with invoicing status and desk allocation kind" do
        let(:status) { :invoicing }
        let(:kinds) { :desk }

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with invoicing status and delivery allocation kind" do
        let(:status) { :invoicing }
        let(:kinds) { :delivery }

        before do
          described_class.invoicing.each do |sell_order|
            sell_order.allocation.update(kind: :delivery)
          end
        end

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with invoicing status and takeout allocation kind" do
        let(:status) { :invoicing }
        let(:kinds) { :takeout }

        before do
          described_class.invoicing.each do |sell_order|
            sell_order.allocation.update(kind: :takeout)
          end
        end

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with closed status and desk allocation kind" do
        let(:status) { :closed }
        let(:kinds) { :desk }

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with closed status and delivery allocation kind" do
        let(:status) { :closed }
        let(:kinds) { :delivery }

        before do
          described_class.closed.each do |sell_order|
            sell_order.allocation.update(kind: :delivery)
          end
        end

        it_behaves_like "current_sales result for sell_orders"
      end

      context "with closed status and takeout allocation kind" do
        let(:status) { :closed }
        let(:kinds) { :takeout }

        before do
          described_class.closed.each do |sell_order|
            sell_order.allocation.update(kind: :takeout)
          end
        end

        it_behaves_like "current_sales result for sell_orders"
      end
    end
    # rubocop:enable RSpec/NestedGroups

    context "with unclosed" do
      include_context "with sell_orders for scopes"

      let(:recent_sell_order) { create(:sell_order, :with_allocation, :as_packed) }

      before { recent_sell_order }

      it "retrieves the corresponding sell_orders" do
        expect(described_class.unclosed.count).to eq(36)
      end

      it "exclude the closed sell_orders status" do
        expect(described_class.unclosed.pluck(:status)).not_to include("closed")
      end

      it "does not include the recent order" do
        expect(described_class.unclosed.pluck(:id)).not_to include(recent_sell_order.id)
      end
    end
  end

  describe "status transitions" do
    before do
      allow(CompleteOrdersJob).to receive(:perform_later)
      allow(CreateBillJob).to receive(:perform_now)
    end

    context "when invoice is executed with opened status and completed suborders" do
      before do
        sell_order.status = "opened"
        sell_order.save
        create(:order, :as_completed, sell_order:)
      end

      it do
        expect { sell_order.invoice }.to change(
          sell_order, :status).from("opened").to("invoicing")
      end

      it do
        sell_order.invoice
        expect(CreateBillJob).to have_received(:perform_now)
      end
    end

    context "when invoice is executed with packed status and packed suborders" do
      before do
        sell_order.status = "packed"
        sell_order.save
        create(:order, :as_packed, sell_order:)
      end

      it do
        expect { sell_order.invoice }.to change(
          sell_order, :status).from("packed").to("invoicing")
      end

      it do
        sell_order.invoice
        expect(CreateBillJob).to have_received(:perform_now)
      end
    end

    context "when invoice is executed with delivering status and packed suborders" do
      before do
        sell_order.status = "delivering"
        sell_order.save
        create(:order, :as_packed, sell_order:)
      end

      it do
        expect { sell_order.invoice }.to change(
          sell_order, :status).from("delivering").to("invoicing")
      end

      it do
        sell_order.invoice
        expect(CreateBillJob).to have_received(:perform_now)
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

      it "raise AASM::InvalidTransition error" do
        expect { sell_order.close }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when close is executed with opened status and is not persisted" do
      include_context "with sell_order close transition valid cash validation"

      it "raise AASM::InvalidTransition error" do
        expect { sell_order.close }.to raise_error(AASM::InvalidTransition)
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
        expect(CreateBillJob).to have_received(:perform_now)
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
        expect(CreateBillJob).not_to have_received(:perform_now)
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
        expect(CreateBillJob).to have_received(:perform_now)
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
        expect(CreateBillJob).to have_received(:perform_now)
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
        expect(CreateBillJob).to have_received(:perform_now)
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
        expect(CreateBillJob).not_to have_received(:perform_now)
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

  describe "#after_validation callback" do
    context "when sell_order does not have an invoicing status" do
      let(:sell_order) { create(:sell_order, :with_associations) }

      before { sell_order.cash_pay = 10 }

      it { expect { sell_order.save }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order does not have a bill associated" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing) }

      before { sell_order.cash_pay = 10 }

      it { expect { sell_order.save }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order does not have a cash payment_type" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing, :with_bill) }

      before { sell_order.cash_pay = 10 }

      it { expect { sell_order.save }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order does not have a total value" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing, :with_cash_payment, :with_bill) }

      before { sell_order.cash_pay = 10 }

      it { expect { sell_order.save }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order does not have a cash_pay value" do
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing, :with_cash_payment, :with_bill) }

      before do
        sell_order.total = sell_order.bill.total
      end

      it { expect { sell_order.save }.not_to change(sell_order, :cash_change) }
    end

    context "when sell_order is able to calculate cash_change value" do
      let(:total) { 75_000 }
      let(:cash_pay) { 100_000 }
      let(:sell_order) { create(:sell_order, :with_associations, :as_invoicing, :with_bill, total:) }

      before do
        sell_order.payment_type = :cash
        sell_order.cash_pay = cash_pay
      end

      it { expect { sell_order.save }.to change(sell_order, :cash_change) }

      it "match the correct cash_change value" do
        sell_order.save
        expect(sell_order.cash_change).to eq(25_000)
      end
    end
  end

  describe "#is_available_to_invoice?" do
    let(:sell_order) { create(:sell_order, :with_allocation) }

    context "with opened sell order and completed suborders returns true" do
      before { create(:order, :as_completed, sell_order:) }

      it { expect(sell_order).to be_is_available_to_invoice }
    end

    context "with opened sell order and opened suborders returns false" do
      before { create(:order, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_invoice }
    end

    context "with packed sell order and packed suborders returns true" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_packed) }

      before { create(:order, :as_packed, sell_order:) }

      it { expect(sell_order).to be_is_available_to_invoice }
    end

    context "with packed sell order and opened suborders returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_packed) }

      before { create(:order, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_invoice }
    end

    context "with delivery sell order without payment and packed suborders returns true" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_delivering, allocation: create(:allocation, :as_delivery)) }

      before { create(:order, :as_packed, sell_order:) }

      it { expect(sell_order).to be_is_available_to_invoice }
    end

    context "with delivery sell order with payment and packed suborders returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_delivering, :with_card_payment, total: 10_000) }

      before { create(:order, :as_packed, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_invoice }
    end

    context "with closed sell order and completed suborders returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_closed) }

      before { create(:order, :as_completed, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_invoice }
    end

    context "with invoicing sell order and completed suborders returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_invoicing) }

      before { create(:order, :as_completed, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_invoice }
    end
  end

  describe "#is_available_to_close?" do
    let(:sell_order) { create(:sell_order, :with_allocation) }

    context "with opened sell order returns false" do
      it { expect(sell_order).not_to be_is_available_to_close }
    end

    context "with packed sell order returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_packed) }

      it { expect(sell_order).not_to be_is_available_to_close }
    end

    context "with delivering sell order without payment returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_delivering) }

      it { expect(sell_order).not_to be_is_available_to_close }
    end

    context "with delivering sell order with payment returns true" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_delivering, :with_card_payment, total: 10_000) }

      it { expect(sell_order).to be_is_available_to_close }
    end

    context "with invoicing sell order without payment returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_invoicing) }

      it { expect(sell_order).not_to be_is_available_to_close }
    end

    context "with invoicing sell order with payment returns true" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_invoicing, :with_card_payment, total: 10_000) }

      it { expect(sell_order).to be_is_available_to_close }
    end
  end

  describe "#is_available_to_deliver?" do
    context "with opened sell order and completed suborders returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation) }

      before { create(:order, :as_completed, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with opened sell order and opened suborders returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation) }

      before { create(:order, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with opened sell order with opened suborders and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation) }

      before { create(:order, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with opened sell order with processing suborders and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation) }

      before { create(:order, :as_processing, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with opened sell order with completed suborders and delivery allocation returns true" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation) }

      before { create(:order, :as_completed, sell_order:) }

      it { expect(sell_order).to be_is_available_to_deliver }
    end

    context "with opened sell order with packed suborders and delivery allocation returns true" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation) }

      before { create(:order, :as_packed, sell_order:) }

      it { expect(sell_order).to be_is_available_to_deliver }
    end

    context "with packed sell order returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_packed) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with packed sell order and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_packed) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with packed sell order with opened suborders and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_packed) }

      before { create(:order, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with packed sell order with packed suborders and delivery allocation returns true" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_packed) }

      before { create(:order, :as_packed, sell_order:) }

      it { expect(sell_order).to be_is_available_to_deliver }
    end

    context "with delivering sell order without payment returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_delivering) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with delivering sell order with payment returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_delivering, :with_card_payment, total: 10_000) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with delivering sell order with opened suborders and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_delivering) }

      before { create(:order, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with delivering sell order with packed suborders and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_delivering) }

      before { create(:order, :as_packed, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with invoicing sell order returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_invoicing) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with invoicing sell order with opened suborders and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_invoicing) }

      before { create(:order, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with invoicing sell order with processing suborders and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_invoicing) }

      before { create(:order, :as_processing, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with invoicing sell order with packed suborders and delivery allocation returns true" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_invoicing) }

      before { create(:order, :as_packed, sell_order:) }

      it { expect(sell_order).to be_is_available_to_deliver }
    end

    context "with invoicing sell order with completed suborders and delivery allocation returns true" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_invoicing) }

      before { create(:order, :as_completed, sell_order:) }

      it { expect(sell_order).to be_is_available_to_deliver }
    end

    context "with invoicing sell order with payment returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_invoicing, :with_card_payment, total: 10_000) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with invoicing sell order with opened suborders and payment returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_invoicing, :with_card_payment, total: 10_000) }

      before { create(:order, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with invoicing sell order with processing suborders and payment returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_invoicing, :with_card_payment, total: 10_000) }

      before { create(:order, :as_processing, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with invoicing sell order with completed suborders and payment returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_invoicing, :with_card_payment, total: 10_000) }

      before { create(:order, :as_completed, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with invoicing sell order with packed suborders and payment returns false" do
      let(:sell_order) { create(:sell_order, :with_allocation, :as_invoicing, :with_card_payment, total: 10_000) }

      before { create(:order, :as_packed, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with closed sell order with packed suborders and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_closed) }

      before { create(:order, :as_packed, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end

    context "with closed sell order with completed suborders and delivery allocation returns false" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_closed) }

      before { create(:order, :as_completed, sell_order:) }

      it { expect(sell_order).not_to be_is_available_to_deliver }
    end
  end
end
