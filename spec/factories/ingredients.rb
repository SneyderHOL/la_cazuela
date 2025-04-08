FactoryBot.define do
  factory :ingredient do
    name { Faker::Food.ingredient }
    unit  { Faker::Number.between(from: 0, to: 1) }
    stored_quantity { 10_0000 }

    trait :with_ml_unit do
      unit { :ml }
    end

    trait :with_mg_unit do
      unit { :mg }
    end

    trait :as_available do
      status { 'available' }
    end

    trait :as_unavailable do
      status { 'unavailable' }
    end
  end
end
