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
        trait_amount { 5 }
      end
      after :create do |order, evaluator|
        create_list :order, evaluator.trait_amount, parent: order
      end
    end

    trait :with_products do
      transient do
        trait_amount { 5 }
      end
      after :create do |order, evaluator|
        create_list :order_product, evaluator.trait_amount, :with_product_and_recipe, order: order
      end
    end
  end
end
