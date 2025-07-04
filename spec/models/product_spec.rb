require 'rails_helper'

RSpec.describe Product, type: :model do
  subject(:product) { build(:product) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'name is not nil' do
      expect(product.name).not_to be_nil
    end

    it 'kind is not nil' do
      expect(product.kind).not_to be_nil
    end

    it 'active is not nil' do
      expect(product.active).not_to be_nil
    end

    it 'price is not nil' do
      expect(product.price).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to have_one(:recipe).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:orders).through(:order_products) }
    it { is_expected.to have_many(:order_products).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it do
      expect(product).to define_enum_for(:kind).with_values({
        dish: 0, beverage: 1, entry: 2, dessert: 3, aside: 4, packing: 5
      }).backed_by_column_of_type(:integer)
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_exclusion_of(:active).in_array([ nil ]) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_length_of(:detail).is_at_most(300).allow_nil }
  end

  describe "scopes" do
    it_behaves_like "active scoping", :product
    it_behaves_like "inactive scoping", :product
  end
end
