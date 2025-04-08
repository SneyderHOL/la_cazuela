FactoryBot.define do
  factory :product do
    name { Faker::Food.dish }
    kind { Faker::Number.between(from: 0, to: 2) }
    active { false }

    trait :is_active do
      active { true }
    end

    trait :dish do
      kind { 0 }
    end

    trait :beverage do
      kind { 1 }
    end

    trait :packing do
      kind { 2 }
    end

    trait :with_recipe do
      transient do
        trait_ingredient_recipe_amount { 5 }
      end
      after :create do |product, evaluator|
        recipe = create(:recipe, product: product)
        create_list :ingredient_recipe, evaluator.trait_ingredient_recipe_amount, :with_ingredient, recipe: recipe
      end
    end
  end
end
