# == Schema Information
#
# Table name: sell_orders
# Database name: primary
#
#  id            :bigint           not null, primary key
#  cash_change   :integer
#  cash_pay      :integer
#  payment_type  :string
#  status        :string           not null
#  total         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  allocation_id :bigint           not null
#
# Indexes
#
#  index_sell_orders_on_allocation_id  (allocation_id)
#
# Foreign Keys
#
#  fk_rails_...  (allocation_id => allocations.id)
#
FactoryBot.define do
  factory :sell_order do
    allocation { nil }
    payment_type { nil }
    total { nil }
    cash_pay { nil }
    cash_change { nil }

    trait :as_closed do
      status { :closed }
    end

    trait :as_delivering do
      status { :delivering }
    end

    trait :as_invoicing do
      status { :invoicing }
    end

    trait :as_packed do
      status { :packed }
    end

    trait :with_cash_payment do
      payment_type { :cash }
    end

    trait :with_transfer_payment do
      payment_type { :transfer }
    end

    trait :with_card_payment do
      payment_type { :card }
    end

    trait :with_orders do
      transient do
        trait_amount { 5 }
        trait_sell_status { status }
      end
      before :create do |sell_order, evaluator|
        evaluator.trait_sell_status
        sell_order.status = :opened
      end
      after :create do |sell_order, evaluator|
        create_list :order, evaluator.trait_amount, :with_products, sell_order: sell_order
        sell_order.update(status: evaluator.trait_sell_status) if evaluator.trait_sell_status
      end
    end

    trait :with_processing_orders do
      transient do
        trait_amount { 5 }
        trait_sell_status { status }
      end
      before :create do |sell_order, evaluator|
        evaluator.trait_sell_status
        sell_order.status = :opened
      end
      after :create do |sell_order, evaluator|
        create_list :order, evaluator.trait_amount, :with_products, sell_order: sell_order
        sell_order.orders.each { |order| order.update(status: :processing) }
        sell_order.update(status: evaluator.trait_sell_status) if evaluator.trait_sell_status
      end
    end

    trait :with_packed_orders do
      transient do
        trait_amount { 5 }
        trait_sell_status { status }
      end
      before :create do |sell_order, evaluator|
        evaluator.trait_sell_status
        sell_order.status = :opened
      end
      after :create do |sell_order, evaluator|
        create_list :order, evaluator.trait_amount, :with_products, sell_order: sell_order
        sell_order.orders.each { |order| order.update(status: :packed) }
        sell_order.update(status: evaluator.trait_sell_status) if evaluator.trait_sell_status
      end
    end

    trait :with_completed_orders do
      transient do
        trait_amount { 5 }
        trait_sell_status { status }
      end
      before :create do |sell_order, evaluator|
        evaluator.trait_sell_status
        sell_order.status = :opened
      end
      after :create do |sell_order, evaluator|
        create_list :order, evaluator.trait_amount, :with_products, sell_order: sell_order
        sell_order.orders.each { |order| order.update(status: :completed) }
        sell_order.update(status: evaluator.trait_sell_status) if evaluator.trait_sell_status
      end
    end

    trait :with_allocation do
      association :allocation, :with_active_on
    end

    trait :with_delivery_allocation do
      association :allocation, :as_delivery, :with_active_on
    end

    trait :with_takeout_allocation do
      association :allocation, :as_takeout, :with_active_on
    end

    trait :with_associations do
      with_processing_orders
      with_allocation
    end

    trait :with_bill do
      after :create do |sell_order, _evaluator|
        create :bill, sell_order: sell_order
      end
    end
  end
end
