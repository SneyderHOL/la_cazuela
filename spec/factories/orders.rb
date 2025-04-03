FactoryBot.define do
  factory :order do
    trait :as_processing do
      status { "processing" }
    end

    trait :as_completed do
      status { "completed" }
    end

    trait :as_closed do
      status { "closed" }
    end

    trait :with_parent_order do
      association :parent, factory: :order
    end

    trait :with_suborders do
      transient do
        amount { 5 }
      end
      after :create do |order, evaluator|
        create_list :order, evaluator.amount, parent: order
      end
    end
  end
end
