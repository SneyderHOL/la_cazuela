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
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:status) }

    context "with product foreign key as unique" do
      before do
        recipe.status = "approved"
        recipe.product = create(:product)
        recipe.save
      end

      it { is_expected.to validate_uniqueness_of(:product_id).allow_nil }
    end

    context "when recipe is not approved is not valid to associate product" do
      before { recipe.product = create(:product) }

      it { is_expected.not_to be_valid }
    end

    context "with ingredient foreign key as unique" do
      before do
        recipe.status = "approved"
        recipe.ingredient = create(:ingredient, :with_base_type)
        recipe.save
      end

      it { is_expected.to validate_uniqueness_of(:ingredient_id).allow_nil }
    end

    context "with a regular ingredient foreign key" do
      before do
        recipe.status = "approved"
        recipe.ingredient = create(:ingredient)
      end

      it { is_expected.not_to be_valid }
    end

    context "with a material ingredient foreign key" do
      before do
        recipe.status = "approved"
        recipe.ingredient = create(:ingredient, :with_material_type)
      end

      it { is_expected.not_to be_valid }
    end

    context "when recipe is not approved is not valid to associate ingredient" do
      before { recipe.ingredient = create(:ingredient) }

      it { is_expected.not_to be_valid }
    end

    context "with approved recipe and is not valid to associate both product and ingredient" do
      before do
        recipe.status = "approved"
        recipe.ingredient = create(:ingredient)
        recipe.product = create(:product)
      end

      it { is_expected.not_to be_valid }
    end

    context "when the ingredient association is included in the recipe's ingredient list" do
      let(:base_ingredient) { create(:ingredient, :with_base_type) }
      let(:recipe_for_base_ingredient) { create(:recipe, :as_approved) }
      let(:ingredient_recipe) do
        create(
          :ingredient_recipe,
          recipe: recipe_for_base_ingredient,
          ingredient: base_ingredient
        )
      end

      before do
        ingredient_recipe
        recipe_for_base_ingredient.ingredient = base_ingredient
      end

      it { expect(recipe_for_base_ingredient).not_to be_valid }
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:product).optional }
    it { is_expected.to belong_to(:ingredient).optional }
    it { is_expected.to have_many(:ingredients).through(:ingredient_recipes) }
    it { is_expected.to have_many(:ingredient_recipes) }
    it { is_expected.to have_many(:order_products) }
  end

  describe "status transitions" do
    describe 'when approve is executed with drafting' do
      before { recipe.status = 'drafting' }

      it do
        expect { recipe.approve }.to change(
          recipe, :status).from("drafting").to("approved")
      end
    end

    describe 'when decline is executed with drafting' do
      before { recipe.status = 'drafting' }

      it do
        expect { recipe.decline }.to change(
          recipe, :status).from("drafting").to("declined")
      end
    end

    describe 'when draft is executed with declined' do
      before { recipe.status = 'declined' }

      it do
        expect { recipe.draft }.to change(
          recipe, :status).from("declined").to("drafting")
      end
    end

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
