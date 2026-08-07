# == Schema Information
#
# Table name: orders
# Database name: primary
#
#  id            :bigint           not null, primary key
#  status        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sell_order_id :bigint           not null
#
# Indexes
#
#  index_orders_on_sell_order_id  (sell_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (sell_order_id => sell_orders.id)
#
FactoryBot.define do
  factory :order do
    trait :as_processing do
      status { "processing" }
    end

    trait :as_completed do
      status { "completed" }
    end

    trait :as_packed do
      status { "packed" }
    end

    trait :with_products do
      transient do
        trait_amount { 5 }
      end
      after :create do |order, evaluator|
        create_list :order_product, evaluator.trait_amount, :with_product_and_recipe, order: order
      end
    end

    trait :with_sell_order do
      sell_order { build(:sell_order, :with_allocation) }
    end
  end
end
