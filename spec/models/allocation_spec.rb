require 'rails_helper'

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
    it { is_expected.to have_many(:orders) }
  end

  describe "validations" do
    it do
      expect(allocation).to define_enum_for(:kind).with_values({
        desk: 0, delivery: 1
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

    context "when free is executed with busy status" do
      before { allocation.status = 'busy' }

      it do
        expect { allocation.free }.to change(
          allocation, :status).from("busy").to("available")
      end
    end

    context "when free is executed from on_hold" do
      before { allocation.status = 'on_hold' }

      it do
        expect { allocation.free }.to change(
          allocation, :status).from("on_hold").to("available")
      end
    end
  end

  describe "scopes" do
    describe "#active" do
      let(:inactive_allocations) { create_list(:allocation, 3) }
      let(:active_allocations) { create_list(:allocation, 2, :with_active_on) }
      let(:allocations) { described_class.active }

      before do
        inactive_allocations
        active_allocations
      end

      it { expect(allocations.count).to be(2) }
      it { expect(allocations.first).to eql(active_allocations.first) }
      it { expect(allocations.last).to eql(active_allocations.last) }
    end

    describe "#inactive" do
      let(:inactive_allocations) { create_list(:allocation, 3) }
      let(:active_allocations) { create_list(:allocation, 2, :with_active_on) }
      let(:allocations) { described_class.inactive }

      before do
        inactive_allocations
        active_allocations
      end

      it { expect(allocations.count).to be(3) }
      it { expect(allocations.first).to eql(inactive_allocations.first) }
      it { expect(allocations.second).to eql(inactive_allocations.second) }
      it { expect(allocations.last).to eql(inactive_allocations.last) }
    end
  end
end
