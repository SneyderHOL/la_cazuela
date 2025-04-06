FactoryBot.define do
  factory :allocation do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    kind { Faker::Number.between(from: 0, to: 1) }
    active { false }

    trait :as_active do
      active { true }
    end

    trait :desk do
      kind { 0 }
    end

    trait :delivery do
      kind { 1 }
    end
  end
end
