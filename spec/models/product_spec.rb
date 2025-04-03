require 'rails_helper'

RSpec.describe Product, type: :model do
  subject(:product) { build(:product) }

  describe "factory object" do
    it 'is valid' do
      expect(product).to be_valid
      expect(product.name).not_to be_nil
      expect(product.kind).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to have_one(:recipe) }
  end

  describe "validations" do
    it do
      is_expected.to define_enum_for(:kind).with_values({
        dish: 0, beverage: 1, packing: 2
      }).backed_by_column_of_type(:integer)
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_exclusion_of(:active).in_array([ nil ]) }
  end
end
