FactoryBot.define do
  factory :ingredient do
    name { Faker::Food.ingredient }
    unit  { Faker::Number.between(from: 0, to: 1) }
    stored_quantity { Faker::Number.between(from: 1, to: 1000) }

    trait :with_ml_unit do
      unit { :ml }
    end

    trait :with_mg_unit do
      unit { :mg }
    end

    trait :available do
      status { 'available' }
    end

    trait :unavailable do
      status { 'unavailable' }
    end
  end
end
