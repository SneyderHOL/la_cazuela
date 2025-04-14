FactoryBot.define do
  factory :ingredient do
    name { Faker::Food.ingredient }
    unit  { :mg }
    stored_quantity { 10_0000 }
    ingredient_type { 'regular' }
    low_threshold { 0 }
    high_threshold { 0 }

    trait :with_ml_unit do
      unit { :ml }
    end

    trait :with_mg_unit do
      unit { :mg }
    end

    trait :with_one_unit do
      unit { :one }
    end

    trait :as_available do
      status { 'available' }
    end

    trait :as_unavailable do
      status { 'unavailable' }
    end

    trait :scarce do
      status { 'scarce' }
    end

    trait :with_base_type do
      ingredient_type { 'base' }
    end

    trait :with_material_type do
      ingredient_type { 'material' }
    end

    trait :with_base_type_and_recipe do
      ingredient_type { 'base' }
      transient do
        trait_ingredient_recipe_amount { 5 }
      end
      after :create do |ingredient, evaluator|
        create(
          :recipe,
          :with_ingredient,
          ingredient: ingredient,
          trait_ingredient_recipe_amount: evaluator.trait_ingredient_recipe_amount
        )
      end
    end
  end
end
