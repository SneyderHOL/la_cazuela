FactoryBot.define do
  factory :order_product do
    order { nil }
    product { nil }
    quantity { Faker::Number.between(from: 1, to: 5) }
    note { nil }

    trait :as_preparing do
      status { "preparing" }
    end

    trait :as_completed do
      status { "completed" }
    end

    trait :with_associations do
      order { build(:order, :with_allocation) }
      association :product
    end

    trait :with_order do
      order { build(:order, :with_allocation) }
    end

    trait :with_product do
      association :product
    end

    trait :with_product_and_recipe do
      product { create(:product, :with_recipe) }
    end
  end
end
