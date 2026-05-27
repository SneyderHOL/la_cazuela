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
