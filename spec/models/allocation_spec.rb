require 'rails_helper'

RSpec.describe Allocation, type: :model do
  subject(:allocation) { build(:allocation) }

  describe "factory object" do
    it 'is valid' do
      expect(allocation).to be_valid
      expect(allocation.name).not_to be_nil
      expect(allocation.kind).not_to be_nil
      expect(allocation.status).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:orders) }
  end

  describe "validations" do
    it do
      is_expected.to define_enum_for(:kind).with_values({
        desk: 0, delivery: 1
      }).backed_by_column_of_type(:integer)
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "status transitions" do
    describe 'take' do
      context "from available" do
        before { allocation.status = 'available' }
        it do
          expect { allocation.take }.to change(
            allocation, :status).from("available").to("busy")
        end
      end

      context "from on_hold" do
        before { allocation.status = 'on_hold' }
        it do
          expect { allocation.take }.to change(
            allocation, :status).from("on_hold").to("busy")
        end
      end
    end

    describe 'free' do
      context "from busy" do
        before { allocation.status = 'busy' }
        it do
          expect { allocation.free }.to change(
            allocation, :status).from("busy").to("available")
        end
      end

      context "from on_hold" do
        before { allocation.status = 'on_hold' }
        it do
          expect { allocation.free }.to change(
            allocation, :status).from("on_hold").to("available")
        end
      end
    end
  end
end
