FactoryBot.define do
  factory :bill do
    sell_order { nil }
    total { 1 }
    detail { "{}" }
  end

  trait :with_sell_order do
    sell_order { build(:sell_order, :with_associations) }
  end
end
