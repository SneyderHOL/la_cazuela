# == Schema Information
#
# Table name: allocations
# Database name: primary
#
#  id         :bigint           not null, primary key
#  active     :boolean          not null
#  kind       :integer          not null
#  name       :string           not null
#  status     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_allocations_on_name  (name) UNIQUE
#
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
