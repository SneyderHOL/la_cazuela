require 'rails_helper'

# == Schema Information
#
# Table name: recipes
# Database name: primary
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  output_quantity :integer          default(1), not null
#  status          :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  ingredient_id   :bigint
#  product_id      :bigint
#
# Indexes
#
#  index_recipes_on_ingredient_id  (ingredient_id) UNIQUE
#  index_recipes_on_name           (name) UNIQUE
#  index_recipes_on_product_id     (product_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (product_id => products.id)
#
RSpec.describe Recipe, type: :model do
  subject(:recipe) { build(:recipe) }

  let(:recipe_with_product) { build(:recipe, :with_product) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'name is not nil' do
      expect(recipe.name).not_to be_nil
    end

    it 'output_quantity is not nil' do
      expect(recipe.output_quantity).not_to be_nil
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
    it { is_expected.to validate_numericality_of(:output_quantity).is_greater_than(0) }

    context "with product foreign key as unique" do
      before do
        recipe.status = "approved"
        recipe.product = create(:product, :with_category)
        recipe.save
      end

      it { is_expected.to validate_uniqueness_of(:product_id).allow_nil }
    end

    context "when recipe is not approved is not valid to associate product" do
      before { recipe.product = create(:product, :with_category) }

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
        recipe.product = create(:product, :with_category)
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
    context 'when approve is executed with drafting' do
      before { recipe.status = 'drafting' }

      it do
        expect { recipe.approve }.to change(
          recipe, :status).from("drafting").to("approved")
      end
    end

    context 'when decline is executed with drafting' do
      before { recipe.status = 'drafting' }

      it do
        expect { recipe.decline }.to change(
          recipe, :status).from("drafting").to("declined")
      end
    end

    context 'when draft is executed with declined' do
      before { recipe.status = 'declined' }

      it do
        expect { recipe.draft }.to change(
          recipe, :status).from("declined").to("drafting")
      end
    end

    context 'when approve is executed with declined' do
      before { recipe.status = 'declined' }

      it do
        expect { recipe.approve }.to change(
          recipe, :status).from("declined").to("approved")
      end
    end

    context 'when declined is executed with approved' do
      before { recipe.status = 'approved' }

      it do
        expect { recipe.decline }.to change(
          recipe, :status).from("approved").to("declined")
      end
    end
  end

  describe "#cost" do
    let(:recipe) { create(:recipe, :with_product, trait_ingredient_recipe_amount: 2) }

    context "when cost is 0" do
      before do
        recipe.ingredient_recipes.each do |ingredient_recipe|
          ingredient_recipe.ingredient.update(cost: 0)
        end
      end

      it { expect(recipe.cost).to eq(0) }
    end

    context "when cost matched the expected value" do
      before do
        recipe.ingredient_recipes.first.ingredient.update(cost: 500, stored_quantity: 2_000)
        recipe.ingredient_recipes.first.update(required_quantity: 5_000)
        recipe.ingredient_recipes.last.ingredient.update(cost: 1_000, stored_quantity: 1_000)
        recipe.ingredient_recipes.last.update(required_quantity: 5_000)
      end

      it { expect(recipe.cost).to eq(6_250) }
    end
  end

  describe "#unit_cost" do
    let(:recipe) { create(:recipe, :with_product, trait_ingredient_recipe_amount: 2) }

    context "when unit_cost is 0" do
      before do
        recipe.ingredient_recipes.each do |ingredient_recipe|
          ingredient_recipe.ingredient.update(cost: 0)
        end
      end

      it { expect(recipe.unit_cost).to eq(0.to_d) }
    end

    context "when unit_cost matched the expected value" do
      before do
        recipe.ingredient_recipes.first.ingredient.update(cost: 500, stored_quantity: 2_000)
        recipe.ingredient_recipes.first.update(required_quantity: 5_000)
        recipe.ingredient_recipes.last.ingredient.update(cost: 1_000, stored_quantity: 1_000)
        recipe.ingredient_recipes.last.update(required_quantity: 5_000)
        recipe.update(output_quantity: 10_000)
      end

      it { expect(recipe.unit_cost).to eq((0.625).to_d) }
    end
  end
end
