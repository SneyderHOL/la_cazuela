FactoryBot.define do
  factory :recipe do
    sequence(:name) { |n| "Recipe ##{} for #{Faker::Commerce.product_name}" }

    trait :approve do
      status { 'approved' }
    end

    trait :decline do
      status { 'declined' }
    end
  end
end
