require 'rails_helper'

RSpec.describe Recipe, type: :model do
  subject(:recipe) { build(:recipe) }

  let(:recipe_with_product) { build(:recipe, :with_product) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'name is not nil' do
      expect(recipe.name).not_to be_nil
    end

    it 'status is not nil' do
      expect(recipe.status).not_to be_nil
    end

    describe 'when build with product' do
      it 'is valid' do
        expect(recipe_with_product).to be_valid
      end

      it 'product is not nil' do
        expect(recipe_with_product.product).not_to be_nil
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:status) }

    describe "with foreign key as unique" do
      before do
        recipe.product = create(:product)
        recipe.save
      end

      it { is_expected.to validate_uniqueness_of(:product_id).allow_nil }
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:product).optional }
    it { is_expected.to have_many(:ingredients).through(:ingredient_recipes) }
    it { is_expected.to have_many(:ingredient_recipes) }
    it { is_expected.to have_many(:order_products) }
  end

  describe "status transitions" do
    describe 'when approve is executed with declined' do
      before { recipe.status = 'declined' }

      it do
        expect { recipe.approve }.to change(
          recipe, :status).from("declined").to("approved")
      end
    end

    describe 'when declined is executed with approved' do
      before { recipe.status = 'approved' }

      it do
        expect { recipe.decline }.to change(
          recipe, :status).from("approved").to("declined")
      end
    end
  end
end
