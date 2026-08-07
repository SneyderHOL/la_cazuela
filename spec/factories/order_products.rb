# == Schema Information
#
# Table name: order_products
# Database name: primary
#
#  id          :bigint           not null, primary key
#  inventoried :boolean
#  note        :string
#  quantity    :integer          not null
#  status      :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  order_id    :bigint           not null
#  product_id  :bigint           not null
#  recipe_id   :bigint
#
# Indexes
#
#  index_order_products_on_order_id    (order_id)
#  index_order_products_on_product_id  (product_id)
#  index_order_products_on_recipe_id   (recipe_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (product_id => products.id)
#
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
