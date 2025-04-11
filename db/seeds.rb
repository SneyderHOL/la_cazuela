# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

allocation_attribute_list = [
  { name: "North Delivery", kind: :delivery, active: false },
  { name: "South Delivery", kind: :delivery, active: false },
  { name: "East Delivery", kind: :delivery, active: false },
  { name: "West Delivery", kind: :delivery, active: false },
  { name: "DownTown Delivery", kind: :delivery, active: true },
  { name: "Desk 1", kind: :desk, active: false },
  { name: "Desk 2", kind: :desk, active: true }
]

user_attribute_list = [
  { name: "Main Waiter", email: "main_waiter@example.com", password: "MySecretPassword+1", role: :waiter, active: true },
  { name: "Aux Waiter", email: "aux_waiter@example.com", password: "MySecretPassword+12", role: :waiter, active: false },
  { name: "Admin", email: "admin@example.com", password: "MySecretPassword+10", role: :admin, active: true }
]

regular_ingredient_attribute_list = []
base_ingredient_attribute_list = []
material_ingredient_attribute_list = []

(1..20).each do
  regular_ingredient_attribute_list << {
    name: Faker::Food.ingredient,
    unit: Faker::Number.between(from: 0, to: 1),
    stored_quantity: 30_0000,
    ingredient_type: :regular,
    low_threshold: Faker::Number.between(from: 10_0000, to: 13_0000),
    high_threshold: Faker::Number.between(from: 16_0000, to: 20_0000)
  }
end

(1..5).each do
  base_ingredient_attribute_list << {
    name: Faker::Food.ingredient,
    unit: Faker::Number.between(from: 0, to: 1),
    stored_quantity: 5_000,
    ingredient_type: :base,
    low_threshold: Faker::Number.between(from: 1_500, to: 2_000),
    high_threshold: Faker::Number.between(from: 3_000, to: 4_000)
  }
end

(1..5).each do |n|
  material_ingredient_attribute_list << {
    name: "Material for #{n} #{'units'.pluralize(n)}",
    unit: 2,
    stored_quantity: 800,
    ingredient_type: :material,
    low_threshold: Faker::Number.between(from: 150, to: 200),
    high_threshold: Faker::Number.between(from: 300, to: 500)
  }
end

ingredient_attribute_list = regular_ingredient_attribute_list +
                            base_ingredient_attribute_list +
                            material_ingredient_attribute_list

draft_recipe_attribute_list = []
declined_recipe_attribute_list = []
approved_recipe_attribute_list = []

(1..3).each do
  draft_recipe_attribute_list << { name: "Recipe for #{Faker::Food.dish}", status: "drafting" }
end

(1..3).each do
  declined_recipe_attribute_list << { name: "Recipe for #{Faker::Food.dish}", status: "declined" }
end

(1..3).each do
  approved_recipe_attribute_list << { name: "Recipe for #{Faker::Food.dish}", status: "approved" }
end

recipe_attribute_list = draft_recipe_attribute_list + declined_recipe_attribute_list +
                        approved_recipe_attribute_list

dish_product_attribute_list = []
beverage_product_attribute_list = []
entry_product_attribute_list = []
dessert_product_attribute_list = [
  { name: "Big Dessert", kind: 4, active: false, price: 10000 },
  { name: "Medium Dessert", kind: 4, active: false, price: 7000 },
]
aside_product_attribute_list = []
packing_product_attribute_list = [
  { name: "Big Packing", kind: 5, active: false, price: 1000 },
  { name: "Medium Packing", kind: 5, active: false, price: 700 },
  { name: "Small Packing", kind: 5, active: false, price: 500 }
]

(1..5).each do
  dish_product_attribute_list << {
    name: Faker::Food.dish, kind: 0, active: false, price: Faker::Number.between(from: 25, to: 70) * 1000
  }
end

(1..5).each do
  beverage_product_attribute_list << {
    name: Faker::Beer.name, kind: 1, active: false, price: Faker::Number.between(from: 5, to: 9) * 1000
  }
end

(1..5).each do
  entry_product_attribute_list << {
    name: Faker::Food.fruits, kind: 2, active: false, price: Faker::Number.between(from: 9, to: 12) * 1000
  }
end

(1..5).each do
  aside_product_attribute_list << {
    name: Faker::Food.sushi, kind: 4, active: false, price: Faker::Number.between(from: 25, to: 70) * 1000
  }
end


product_attribute_list = dish_product_attribute_list + beverage_product_attribute_list +
                         entry_product_attribute_list + dessert_product_attribute_list +
                         aside_product_attribute_list + packing_product_attribute_list

p "Creating users ..."

user_attribute_list.each do |user|
  User.create_with(
    name: user[:name], password: user[:password], role: user[:role], active: user[:active]
  ).find_or_create_by(email: user[:email])
end

p "Creating allocations ..."

allocation_attribute_list.each do |allocation|
  Allocation.create_with(
    kind: allocation[:kind], active: allocation[:active]
  ).find_or_create_by(name: allocation[:name])
end

p "Creating ingredients ..."

ingredient_attribute_list.each do |ingredient|
  Ingredient.create_with(
    unit: ingredient[:unit],
    stored_quantity: ingredient[:stored_quantity],
    ingredient_type: ingredient[:ingredient_type],
    low_threshold: ingredient[:low_threshold],
    high_threshold: ingredient[:high_threshold]
  ).find_or_create_by(name: ingredient[:name])
end

p "Creating recipes ..."

recipe_attribute_list.each do |recipe|
  Recipe.create_with(status: recipe[:status]).find_or_create_by(name: recipe[:name])
end

p "Creating products ..."

product_attribute_list.each do |product|
  Product.create_with(
    kind: product[:kind], active: product[:active], price: product[:price]
  ).find_or_create_by(name: product[:name])
end

ingredients = Ingredient.regular.limit(9)

recipes = Recipe.approved.where(product_id: nil).where(ingredient_id: nil).limit(3)

p "Creating ingredient recipes ..."

ingredients.each_with_index do |ingredient, index|
  IngredientRecipe.create(ingredient: ingredient, recipe: recipes[index%recipes.size], required_quantity: 10)
end

p "Assigning recipes ..."

products = Product.where.not(id: Recipe.all.pluck(:product_id)).inactive.limit(1)
base_ingredients = Ingredient.where.not(id: Recipe.all.pluck(:ingredient_id)).base.limit(1)

recipe_holders = products + base_ingredients
recipes[0..1].each_with_index { |recipe, index| recipe.update(product: products[index]) }

recipes.last.update(ingredient: base_ingredients.first)

p "Activating products ..."
products.each do |product|
  product.toggle!(:active)
end

p "Creating order ..."
allocation = Allocation.active.desk.first
order = Order.create(allocation: allocation)

p "Creating order products ..."

products.each do |product|
  OrderProduct.create(order: order, product: product, quantity: 1)
end

p "Creating suborder ..."
suborder = Order.create(allocation: allocation, parent: order)

p "Creating order products for suborder ..."

OrderProduct.create(order: suborder, product: products.first, quantity: 1)
