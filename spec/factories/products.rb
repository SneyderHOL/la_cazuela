FactoryBot.define do
  factory :product do
    name { Faker::Food.dish }
    kind { Faker::Number.between(from: 0, to: 5) }
    active { false }

    trait :with_active_on do
      active { true }
    end

    trait :dish do
      kind { 0 }
    end

    trait :beverage do
      kind { 1 }
    end

    trait :entry do
      kind { 2 }
    end

    trait :dessert do
      kind { 3 }
    end

    trait :aside do
      kind { 4 }
    end

    trait :packing do
      kind { 5 }
    end

    trait :with_recipe do
      transient do
        trait_ingredient_recipe_amount { 5 }
      end
      after :create do |product, evaluator|
        recipe = create(:recipe, :as_approved, product: product)
        create_list :ingredient_recipe, evaluator.trait_ingredient_recipe_amount, :with_ingredient, recipe: recipe
      end
    end
  end
end
