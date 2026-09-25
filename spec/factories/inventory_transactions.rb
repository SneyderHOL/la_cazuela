# == Schema Information
#
# Table name: inventory_transactions
# Database name: primary
#
#  id               :bigint           not null, primary key
#  by_admin         :boolean          default(FALSE), not null
#  cost             :integer          default(0), not null
#  direction        :string           not null
#  error_message    :string
#  quantity         :integer          not null
#  status           :string           not null
#  transaction_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  ingredient_id    :bigint           not null
#  order_product_id :bigint
#
# Indexes
#
#  index_inventory_transactions_on_ingredient_id     (ingredient_id)
#  index_inventory_transactions_on_order_product_id  (order_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (order_product_id => order_products.id)
#
FactoryBot.define do
  factory :inventory_transaction do
    ingredient { nil }
    order_product { nil }
    quantity { Faker::Number.between(from: 1, to: 50) }
    direction { :addition }
    cost { 0 }
    by_admin { false }
    transaction_type { :purchase }

    trait :as_pending do
      status { "pending" }
    end

    trait :as_completed do
      status { "completed" }
    end

    trait :as_production_type do
      transaction_type { :production }
    end

    trait :as_adjustment_type do
      transaction_type { :adjustment }
    end

    trait :as_consumption_type do
      transaction_type { :consumption }
    end

    trait :with_ingredient do
      association :ingredient
    end

    trait :with_order_product do
      association :order_product
    end

    trait :as_subtraction do
      direction { :subtraction }
    end

    trait :performed_by_admin do
      by_admin { true }
    end
  end
end
