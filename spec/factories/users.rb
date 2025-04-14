FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    role { :waiter }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    nickname { nil }
    active { false }

    trait :with_active_on do
      active { true }
    end

    trait :with_admin_role do
      role { :admin }
    end
  end
end
