require 'rails_helper'

RSpec.describe Category, type: :model do
  subject(:category) { build(:category) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it "name is not nil" do
      expect(category.name).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:products).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe "scopes" do
    it_behaves_like "active scoping", :category
    it_behaves_like "inactive scoping", :category
  end

  describe "ancestry" do
    include_context "with a category tree"

    it "match the categories count" do
      expect(described_class.count).to eq(5)
    end

    it "match the current categories plus the descendants count" do
      expect(dish_category.subtree.count).to eq(5)
    end

    it "match the descendants categories count" do
      expect(dish_category.descendants.count).to eq(4)
    end

    it "match the children categories count" do
      expect(dish_category.children.count).to eq(3)
    end
  end
end
