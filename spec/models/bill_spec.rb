require 'rails_helper'

RSpec.describe Bill, type: :model do
  subject(:bill) { build(:bill, :with_order) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'total is not nil' do
      expect(bill.total).not_to be_nil
    end

    it 'detail is not nil' do
      expect(bill.detail).not_to be_nil
    end

    it 'order is not nil' do
      expect(bill.order).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:order) }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:total).is_greater_than_or_equal_to(0) }
  end
end
