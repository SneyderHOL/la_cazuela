# == Schema Information
#
# Table name: funds
# Database name: primary
#
#  id               :bigint           not null, primary key
#  amount           :integer          not null
#  detail           :string           not null
#  is_deposit       :boolean          not null
#  transaction_date :date             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_funds_on_transaction_date  (transaction_date)
#
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
