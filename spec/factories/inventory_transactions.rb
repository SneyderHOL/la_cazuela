# == Schema Information
#
# Table name: inventory_transactions
# Database name: primary
#
#  id            :bigint           not null, primary key
#  by_admin      :boolean          default(FALSE), not null
#  cost          :integer          default(0), not null
#  error_message :string
#  kind          :integer          not null
#  quantity      :integer          not null
#  status        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint           not null
#
# Indexes
#
#  index_inventory_transactions_on_ingredient_id  (ingredient_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#
FactoryBot.define do
  factory :inventory_transaction do
    ingredient { nil }
    quantity { Faker::Number.between(from: 1, to: 50) }
    kind { Faker::Number.between(from: 0, to: 1) }
    cost { Faker::Number.between(from: 30, to: 100) }
    by_admin { false }

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

    trait :performed_by_admin do
      by_admin { true }
    end
  end
end
