FactoryBot.define do
  factory :recipe do
    sequence(:name) { |n| "Recipe ##{n} #{Faker::Food.dish}" }
    product { nil }

    trait :approve do
      status { 'approved' }
    end

    trait :decline do
      status { 'declined' }
    end

    trait :with_product do
      association :product
      transient do
        trait_ingredient_recipe_amount { 5 }
      end
      after :create do |recipe, evaluator|
        create_list :ingredient_recipe, evaluator.trait_ingredient_recipe_amount, :with_ingredient, recipe: recipe
      end
    end
  end
end
