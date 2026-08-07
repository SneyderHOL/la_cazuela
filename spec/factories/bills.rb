# == Schema Information
#
# Table name: bills
# Database name: primary
#
#  id            :bigint           not null, primary key
#  detail        :jsonb
#  total         :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sell_order_id :bigint           not null
#
# Indexes
#
#  index_bills_on_sell_order_id  (sell_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (sell_order_id => sell_orders.id)
#
FactoryBot.define do
  factory :bill do
    sell_order { nil }
    total { 5_000 }
    detail { { Faker::Food.dish => { "quantity" => 1, "subtotal": 5_000 } } }
  end

  trait :with_sell_order do
    sell_order { build(:sell_order, :with_associations) }
  end
end
