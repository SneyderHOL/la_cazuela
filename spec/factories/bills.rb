FactoryBot.define do
  factory :bill do
    order { nil }
    total { 1 }
    detail { "{}" }
  end

  trait :with_order do
    order { build(:order, :with_allocation) }
  end
end
