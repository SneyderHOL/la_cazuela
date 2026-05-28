FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "#{Faker::Food.dish} #{n}" }
    active { false }
    price { Faker::Number.between(from: 1_000, to: 50_000) }
    category { nil }

    trait :with_active_on do
      active { true }
    end

    trait :dish do
      category { build(:category, name: "Dish") }
    end

    trait :beverage do
      category { build(:category, name: "Beverage") }
    end

    trait :entry do
      category { build(:category, name: "Entry") }
    end

    trait :dessert do
      category { build(:category, name: "Dessert") }
    end

    trait :aside do
      category { build(:category, name: "Aside") }
    end

    trait :packing do
      category { build(:category, name: "Packing") }
    end

    trait :with_recipe do
      transient do
        trait_ingredient_recipe_amount { 5 }
      end
      after :create do |product, evaluator|
        recipe = create(:recipe, :as_approved, product: product)
        create_list :ingredient_recipe, evaluator.trait_ingredient_recipe_amount, :with_ingredient, recipe: recipe
      end
    end

    trait :with_category do
      category { build(:category) } if category.nil?
    end
  end
end
