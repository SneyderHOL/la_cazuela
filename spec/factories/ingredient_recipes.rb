# == Schema Information
#
# Table name: ingredient_recipes
# Database name: primary
#
#  id                :bigint           not null, primary key
#  required_quantity :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ingredient_id     :bigint           not null
#  recipe_id         :bigint           not null
#
# Indexes
#
#  index_ingredient_recipes_on_ingredient_id                (ingredient_id)
#  index_ingredient_recipes_on_ingredient_id_and_recipe_id  (ingredient_id,recipe_id) UNIQUE
#  index_ingredient_recipes_on_recipe_id                    (recipe_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (recipe_id => recipes.id)
#
FactoryBot.define do
  factory :ingredient_recipe do
    ingredient { nil }
    recipe { nil }
    required_quantity { Faker::Number.between(from: 1, to: 300) }

    trait :with_associations do
      association :ingredient
      association :recipe
    end

    trait :with_ingredient do
      association :ingredient
    end

    trait :with_recipe do
      association :recipe
    end
  end
end
