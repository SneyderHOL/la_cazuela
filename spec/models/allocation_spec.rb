require 'rails_helper'

# == Schema Information
#
# Table name: allocations
# Database name: primary
#
#  id         :bigint           not null, primary key
#  active     :boolean          not null
#  kind       :integer          not null
#  name       :string           not null
#  status     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_allocations_on_name  (name) UNIQUE
#
RSpec.describe Allocation, type: :model do
  subject(:allocation) { build(:allocation) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it "name is not nil" do
      expect(allocation.name).not_to be_nil
    end

    it "kind is not nil" do
      expect(allocation.kind).not_to be_nil
    end

    it "status is not nil" do
      expect(allocation.status).not_to be_nil
    end

    it "active is not nil" do
      expect(allocation.active).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:sell_orders).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it do
      expect(allocation).to define_enum_for(:kind).with_values({
        desk: 0, delivery: 1, takeout: 2
      }).backed_by_column_of_type(:integer)
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_exclusion_of(:active).in_array([ nil ]) }
  end

  describe "status transitions" do
    context "when take is executed with available status" do
      before { allocation.status = 'available' }

      it do
        expect { allocation.take }.to change(
          allocation, :status).from("available").to("busy")
      end
    end

    context "when take is executed with on_hold status" do
      before { allocation.status = 'on_hold' }

      it do
        expect { allocation.take }.to change(
          allocation, :status).from("on_hold").to("busy")
      end
    end

    context "when take is executed with cleaning status" do
      before { allocation.status = 'cleaning' }

      it do
        expect { allocation.take }.to change(
          allocation, :status).from("cleaning").to("busy")
      end
    end

    context "when free is executed with busy status" do
      before { allocation.status = 'busy' }

      it do
        expect { allocation.free }.to change(
          allocation, :status).from("busy").to("available")
      end
    end

    context "when free is executed with busy status and an opened sell order" do
      let(:sell_order) { create(:sell_order, allocation:) }

      before do
        allocation.status = 'busy'
        sell_order
      end

      it "raise AASM::InvalidTransition error" do
        expect { allocation.free }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when free is executed from on_hold" do
      before { allocation.status = 'on_hold' }

      it do
        expect { allocation.free }.to change(
          allocation, :status).from("on_hold").to("available")
      end
    end

    context "when free is executed from cleaning" do
      before { allocation.status = 'cleaning' }

      it do
        expect { allocation.free }.to change(
          allocation, :status).from("cleaning").to("available")
      end
    end

    context "when clean is executed from available" do
      before { allocation.status = 'available' }

      it do
        expect { allocation.clean }.to change(
          allocation, :status).from("available").to("cleaning")
      end
    end

    context "when clean is executed from on_hold" do
      before { allocation.status = 'on_hold' }

      it do
        expect { allocation.clean }.to change(
          allocation, :status).from("on_hold").to("cleaning")
      end
    end

    context "when clean is executed from busy" do
      before { allocation.status = 'busy' }

      it do
        expect { allocation.clean }.to change(
          allocation, :status).from("busy").to("cleaning")
      end
    end

    context "when clean is executed from busy and an opened sell order" do
      let(:sell_order) { create(:sell_order, allocation:) }

      before do
        allocation.status = 'busy'
        sell_order
      end

      it "raise AASM::InvalidTransition error" do
        expect { allocation.clean }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when reserve is executed with available status" do
      before { allocation.status = 'available' }

      it do
        expect { allocation.reserve }.to change(
          allocation, :status).from("available").to("on_hold")
      end
    end

    context "when reserve is executed with busy status" do
      before { allocation.status = 'busy' }

      it "raise AASM::InvalidTransition error" do
        expect { allocation.reserve }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when reserve is executed with cleaning status" do
      before { allocation.status = 'cleaning' }

      it do
        expect { allocation.reserve }.to change(
          allocation, :status).from("cleaning").to("on_hold")
      end
    end
  end

  describe "scopes" do
    it_behaves_like "active scoping", :allocation
    it_behaves_like "inactive scoping", :allocation

    context "with active_service" do
      include_context "with sell_orders for scopes"

      before do
        SellOrder.closed.each do |sell_order|
          sell_order.allocation.update(status: :cleaning)
        end
        SellOrder.delivering.each do |sell_order|
          sell_order.allocation.update(status: :busy)
        end
        SellOrder.invoicing.each do |sell_order|
          sell_order.allocation.update(status: :on_hold)
        end
      end

      let(:kinds) { %i[ desk delivery takeout ] }
      let(:statuses) { %i[available busy on_hold cleaning] }

      it "retrieves the corresponding allocations" do
        expect(described_class.active_service(kinds, statuses).count).to eq(45)
      end

      it "retrieves the corresponding desk allocations" do
        expect(described_class.active_service(kinds, statuses).desk.count).to eq(36)
      end

      it "retrieves the corresponding delivery allocations" do
        expect(described_class.active_service(kinds, statuses).delivery.count).to eq(9)
      end

      it "retrieves the corresponding takeout allocations" do
        expect(described_class.active_service(kinds, statuses).takeout.count).to eq(0)
      end

      it "retrieves the corresponding available allocations" do
        expect(described_class.active_service(kinds, statuses).available.count).to eq(18)
      end

      it "retrieves the corresponding busy allocations" do
        expect(described_class.active_service(kinds, statuses).busy.count).to eq(9)
      end

      it "retrieves the corresponding on_hold allocations" do
        expect(described_class.active_service(kinds, statuses).on_hold.count).to eq(9)
      end

      it "retrieves the corresponding cleaning allocations" do
        expect(described_class.active_service(kinds, statuses).cleaning.count).to eq(9)
      end

      it "retrieves the corresponding active value for allocations" do
        expect(described_class.active_service(kinds, statuses).pluck(:active).uniq).to eq([ true ])
      end

      it "retrieves the corresponding status value for allocations" do
        expect(described_class.active_service(kinds, statuses).pluck(:status).uniq).to contain_exactly("available", "busy", "on_hold", "cleaning")
      end
    end
  end

  describe "#current_open_sell_order" do
    include_context "with sell_orders for scopes"

    let(:sell_order) { SellOrder.opened.sales_by_date(saturday).first }
    let(:allocation) { sell_order.allocation }

    before { sell_order }

    context "with sell order" do
      it "retrieves the corresponding sell_order" do
        specific_date = saturday + 3.hours

        travel_to specific_date do
          expect(allocation.current_open_sell_order).to eq(sell_order)
        end
      end
    end

    context "with no sell order" do
      it "return nil" do
        specific_date = friday + 3.hours

        travel_to specific_date do
          expect(allocation.current_open_sell_order).to be_nil
        end
      end
    end
  end
end
