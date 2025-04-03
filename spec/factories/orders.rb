FactoryBot.define do
  factory :order do
    trait :as_in_process do
      status { "in_process" }
    end

    trait :as_completed do
      status { "completed" }
    end

    trait :as_closed do
      status { "closed" }
    end
  end
end
