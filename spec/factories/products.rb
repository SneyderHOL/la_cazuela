FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    kind { Faker::Number.between(from: 0, to: 2) }
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

    trait :packing do
      kind { 2 }
    end
  end
end
