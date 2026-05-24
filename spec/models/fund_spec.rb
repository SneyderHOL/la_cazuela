require 'rails_helper'

RSpec.describe Fund, type: :model do
  subject(:deposit_fund) { build(:fund, :as_deposit) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it "detail is not nil" do
      expect(deposit_fund.detail).not_to be_nil
    end

    it "amount is not nil" do
      expect(deposit_fund.amount).not_to be_nil
    end

    it "is_deposit is not nil" do
      expect(deposit_fund.is_deposit).not_to be_nil
    end

    context "when fund is not a deposit" do
      let(:non_deposit_fund) { build(:fund) }

      it { expect(non_deposit_fund).not_to be_valid }
    end
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:detail) }
    it { is_expected.to validate_presence_of(:transaction_date).on(:create) }
    it { is_expected.to validate_exclusion_of(:is_deposit).in_array([ nil ]) }
  end

  describe "custom validations" do
    context "when fund is a deposit and there is no previous record on the same day" do
      it { expect { deposit_fund.save }.to change(described_class, :count).by(1) }
    end

    context "when fund is a deposit and there is a previous record on the same day" do
      before { create(:fund, :as_deposit) }

      it { expect { deposit_fund.save }.not_to change(described_class, :count) }

      it "with error message" do
        deposit_fund.valid?
        expect(deposit_fund.errors.full_messages).to eq([ "Transaction date has already been taken" ])
      end
    end

    context "when fund is not a deposit and there is no deposit record on the same day" do
      let(:non_deposit_fund) { build(:fund) }

      it { expect { non_deposit_fund.save }.not_to change(described_class, :count) }

      it "with error message" do
        non_deposit_fund.valid?
        expect(non_deposit_fund.errors.full_messages).to eq([ "there is no deposit of the day" ])
      end
    end

    context "when fund is not a deposit and there is a record on the same day" do
      let(:non_deposit_fund) { build(:fund) }

      before { create(:fund, :as_deposit) }

      it { expect { non_deposit_fund.save }.to change(described_class, :count).by(1) }
    end
  end
end
