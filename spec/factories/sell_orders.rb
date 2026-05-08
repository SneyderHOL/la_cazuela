FactoryBot.define do
  factory :sell_order do
    allocation { nil }
    payment_type { :transfer }
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

    trait :with_cash do
      payment_type { :cash }
      total { 9 }
      cash_pay { 10 }
      cash_change { 1 }
    end

    trait :with_transfer do
      payment_type { :transfer }
    end

    trait :with_card do
      payment_type { :card }
    end

    trait :with_orders do
      transient do
        trait_amount { 5 }
      end
      after :create do |sell_order, evaluator|
        create_list :order, evaluator.trait_amount, sell_order: sell_order
      end
    end

    trait :with_processing_orders do
      transient do
        trait_amount { 5 }
      end
      after :create do |sell_order, evaluator|
        create_list :order, evaluator.trait_amount, :as_processing, sell_order: sell_order
      end
    end

    trait :with_packed_orders do
      transient do
        trait_amount { 5 }
      end
      after :create do |sell_order, evaluator|
        create_list :order, evaluator.trait_amount, :as_packed, sell_order: sell_order
      end
    end

    trait :with_completed_orders do
      transient do
        trait_amount { 5 }
      end
      after :create do |sell_order, evaluator|
        create_list :order, evaluator.trait_amount, :as_completed, sell_order: sell_order
      end
    end

    trait :with_allocation do
      association :allocation
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
