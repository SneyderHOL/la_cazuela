# == Schema Information
#
# Table name: recipes
# Database name: primary
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  status        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint
#  product_id    :bigint
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
FactoryBot.define do
  factory :recipe do
    sequence(:name) { |n| "Recipe ##{n} #{Faker::Food.dish}" }
    product { nil }
    ingredient { nil }

    trait :as_approved do
      status { 'approved' }
    end

    trait :as_declined do
      status { 'declined' }
    end

    trait :with_product do
      product { build(:product, :with_recipe, :with_category) }
      status { 'approved' }
      transient do
        trait_ingredient_recipe_amount { 5 }
      end
      after :create do |recipe, evaluator|
        create_list :ingredient_recipe, evaluator.trait_ingredient_recipe_amount, :with_ingredient, recipe: recipe
      end
    end

    trait :with_ingredient do
      ingredient { build(:ingredient, :with_base_type) }
      status { 'approved' }
      transient do
        trait_ingredient_recipe_amount { 5 }
      end
      after :create do |recipe, evaluator|
        create_list :ingredient_recipe, evaluator.trait_ingredient_recipe_amount, :with_ingredient, recipe: recipe
      end
    end
  end
end
