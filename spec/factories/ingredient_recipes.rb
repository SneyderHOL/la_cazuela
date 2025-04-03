FactoryBot.define do
  factory :ingredient_recipe do
    ingredient { nil }
    recipe { nil }
    required_quantity { Faker::Number.between(from: 1, to: 300) }

    trait :with_associations do
      association :ingredient
      association :recipe
    end

    trait :with_ingredient do
      association :ingredient
    end

    trait :with_recipe do
      association :recipe
    end
  end
end
