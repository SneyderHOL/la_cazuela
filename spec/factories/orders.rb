FactoryBot.define do
  factory :base_order, class: "Order" do
    parent { nil }
    allocation { nil }

    trait :as_processing do
      status { "processing" }
    end

    trait :as_completed do
      status { "completed" }
    end

    trait :as_closed do
      status { "closed" }
    end

    trait :with_allocation do
      association :allocation
    end

    trait :with_products do
      transient do
        trait_amount { 5 }
      end
      after :create do |order, evaluator|
        create_list :order_product, evaluator.trait_amount, :with_product_and_recipe, order: order
      end
    end

    factory :order do
      trait :with_suborders do
        transient do
          trait_amount { 5 }
        end
        after :create do |order, evaluator|
          create_list :suborder, evaluator.trait_amount, parent: order, allocation: order.allocation
        end
      end

      trait :with_completed_suborders do
        transient do
          trait_amount { 5 }
        end
        after :create do |order, evaluator|
          create_list :suborder, evaluator.trait_amount, :as_completed, parent: order, allocation: order.allocation
        end
      end
    end

    factory :suborder, class: "Order" do
      trait :with_parent_order do
        parent { build(:order, :with_allocation) }
      end

      trait :with_associations do
        parent { build(:order, :with_allocation) }
        allocation { parent.allocation }
      end
    end
  end
end
