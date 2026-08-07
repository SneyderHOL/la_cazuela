# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                     :bigint           not null, primary key
#  active                 :boolean          default(FALSE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string
#  nickname               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role                  (role)
#
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    role { :kitchen_auxiliar }
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

    trait :with_waiter_role do
      role { :waiter }
    end

    trait :with_cashier_role do
      role { :cashier }
    end
  end
end
