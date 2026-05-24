FactoryBot.define do
  factory :fund do
    detail { Faker::Lorem.sentence(word_count: 3) }
    amount { Faker::Number.between(from: 1_000, to: 30_000) }
    is_deposit { false }
    transaction_date { Time.zone.now.to_date }

    trait :as_deposit do
      is_deposit { true }
    end
  end
end
