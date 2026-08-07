require 'rails_helper'

# == Schema Information
#
# Table name: bills
# Database name: primary
#
#  id            :bigint           not null, primary key
#  detail        :jsonb
#  total         :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sell_order_id :bigint           not null
#
# Indexes
#
#  index_bills_on_sell_order_id  (sell_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (sell_order_id => sell_orders.id)
#
RSpec.describe Bill, type: :model do
  subject(:bill) { build(:bill, :with_sell_order) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'total is not nil' do
      expect(bill.total).not_to be_nil
    end

    it 'detail is not nil' do
      expect(bill.detail).not_to be_nil
    end

    it 'sell_order is not nil' do
      expect(bill.sell_order).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:sell_order) }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:total).is_greater_than(0) }

    context "when detail is empty" do
      before { bill.detail = {} }

      it { is_expected.not_to be_valid }

      it "must have an detail error message" do
        bill.valid?
        expect(bill.errors.full_messages).to eq([ "Detail cannot be empty" ])
      end
    end
  end
end
