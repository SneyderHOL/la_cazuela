FactoryBot.define do
  factory :inventory_transaction do
    ingredient { nil }
    quantity { Faker::Number.between(from: 1, to: 50) }
    kind { Faker::Number.between(from: 0, to: 1) }

    trait :as_pending do
      status { "pending" }
    end

    trait :as_completed do
      status { "completed" }
    end

    trait :with_ingredient do
      association :ingredient
    end

    trait :as_addition do
      kind { :addition }
    end

    trait :as_substraction do
      kind { :substraction }
    end
  end
end
