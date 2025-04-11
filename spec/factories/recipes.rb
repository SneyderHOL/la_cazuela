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
      association :product
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
