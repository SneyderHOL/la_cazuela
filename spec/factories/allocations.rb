FactoryBot.define do
  factory :allocation do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    kind { :desk }
    active { false }

    trait :with_active_on do
      active { true }
    end

    trait :as_desk do
      kind { :desk }
    end

    trait :as_delivery do
      kind { :delivery }
    end
  end
end
