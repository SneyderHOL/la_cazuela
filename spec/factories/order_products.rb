FactoryBot.define do
  factory :order_product do
    order { nil }
    product { nil }
    quantity { Faker::Number.between(from: 1, to: 5) }
    note { nil }
    inventoried { nil }

    trait :as_prepare do
      status { "prepare" }
    end

    trait :as_preparing do
      status { "preparing" }
    end

    trait :as_completed do
      status { "completed" }
    end

    trait :with_associations do
      order { build(:order, :with_sell_order) }
      product { build(:product, :with_recipe, :with_category) }
    end

    trait :with_order do
      order { build(:order, :with_sell_order) }
    end

    trait :with_product do
      product { build(:product, :with_recipe, :with_category) }
    end

    trait :with_product_and_recipe do
      product { build(:product, :with_recipe, :with_category) }
    end
  end
end
