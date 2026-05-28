FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "#{Faker::Food.ethnic_category} #{n}" }
    active { false }

    trait :with_active_on do
      active { true }
    end

    trait :with_products do
      transient do
        trait_products_amount { 3 }
      end
      after :create do |category, evaluator|
        create_list :product, evaluator.trait_products_amount, category: category
      end
    end
  end
end
