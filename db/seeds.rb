# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
return unless Rails.env.development?

allocation_attribute_list = [
  { name: "North Delivery", kind: :delivery, active: false },
  { name: "South Delivery", kind: :delivery, active: false },
  { name: "East Delivery", kind: :delivery, active: true },
  { name: "West Delivery", kind: :delivery, active: false },
  { name: "DownTown Delivery", kind: :delivery, active: true },
  { name: "Desk 1", kind: :desk, active: true },
  { name: "Desk 2", kind: :desk, active: false },
  { name: "Desk 3", kind: :desk, active: true },
  { name: "Desk 4", kind: :desk, active: true },
  { name: "Desk 5", kind: :desk, active: false },
  { name: "Desk 6", kind: :desk, active: false },
  { name: "Takeout", kind: :desk, active: true }
]

user_attribute_list = [
  { name: "Main Waiter", email: "main_waiter@example.com", password: "MySecretPassword+1", role: :waiter, active: true, nickname: "Mwaiter" },
  { name: "Aux Waiter", email: "aux_waiter@example.com", password: "MySecretPassword+12", role: :waiter, active: false, nickname: "Awaiter" },
  { name: "Main Cheff", email: "main_cheff@example.com", password: "MySecretPassword+13", role: :kitchen_auxiliar, active: true, nickname: "Mcheff" },
  { name: "Sub Cheff", email: "sub_cheff@example.com", password: "MySecretPassword+14", role: :kitchen_auxiliar, active: false, nickname: "Scheff" },
  { name: "Admin", email: "admin@example.com", password: "MySecretPassword+10", role: :admin, active: true }
]

regular_ingredient_attribute_list = []
base_ingredient_attribute_list = []
material_ingredient_attribute_list = []

(1..20).each do
  regular_ingredient_attribute_list << {
    name: Faker::Food.ingredient,
    unit: Faker::Number.between(from: 0, to: 1),
    stored_quantity: 30_000,
    ingredient_type: :regular,
    low_threshold: Faker::Number.between(from: 10_000, to: 13_000),
    high_threshold: Faker::Number.between(from: 16_000, to: 20_000),
    cost: Faker::Number.between(from: 1_000, to: 50_000)
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
  { name: "Medium Dessert", kind: 4, active: false, price: 7000 }
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

p "Creating ingredient_recipes ..."

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

p "Creating ingredients for suborders ..."

# Magic Sauce
ingred_soy = Ingredient.create_with(unit: "ml", stored_quantity: 50_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 20_000, cost: 10_000).find_or_create_by(name: "Soy")
ingred_water_tap = Ingredient.create_with(unit: "ml", stored_quantity: 50_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 20_000, cost: 10_000).find_or_create_by(name: "Water Tap")
ingred_tomato_sauce = Ingredient.create_with(unit: "ml", stored_quantity: 50_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 20_000, cost: 10_000).find_or_create_by(name: "Tomato Sauce")
ingred_lemon_juice = Ingredient.create_with(unit: "ml", stored_quantity: 50_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 20_000, cost: 10_000).find_or_create_by(name: "Lemon Juice")
# Super Chicken Bowl
ingred_magic_sauce = Ingredient.create_with(unit: "ml", stored_quantity: 50_000, ingredient_type: "base", low_threshold: 1_000, high_threshold: 20_000, cost: 10_000).find_or_create_by(name: "Magic Sauce")
ingred_olive_oil = Ingredient.create_with(unit: "ml", stored_quantity: 50_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 20_000, cost: 10_000).find_or_create_by(name: "Olive Oil EV")
ingred_ocean_salt = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Ocean Salt")
ingred_oregano = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Oregano")
ingred_chicken = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Chicken")
# Spaguetti
ingred_pasta = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Pasta")
# Coco Rice
ingred_coconut = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Coconut")
ingred_rice = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Rice")
# Tiramisu
ingred_tiramisu = Ingredient.create_with(unit: "one", stored_quantity: 100, ingredient_type: "regular", low_threshold: 10, high_threshold: 70, cost: 10_000).find_or_create_by(name: "Tiramisu")
# Fish
ingred_fish = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Fish")
# Lemonade
ingred_lemon = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Lemon")
ingred_sugar = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Sugar")
ingred_sparkling_water = Ingredient.create_with(unit: "ml", stored_quantity: 50_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 20_000, cost: 10_000).find_or_create_by(name: "Sparkling Water")
# Soda
ingred_soda = Ingredient.create_with(unit: "one", stored_quantity: 100, ingredient_type: "regular", low_threshold: 10, high_threshold: 70, cost: 10_000).find_or_create_by(name: "Soda")
# Panela
ingred_panela = Ingredient.create_with(unit: "mg", stored_quantity: 10_000, ingredient_type: "regular", low_threshold: 1_000, high_threshold: 7_000, cost: 10_000).find_or_create_by(name: "Panela")
# Packing
ingred_large_bowl = Ingredient.create_with(unit: "one", stored_quantity: 100, ingredient_type: "material", low_threshold: 10, high_threshold: 70, cost: 10_000).find_or_create_by(name: "Large Bowl")
ingred_medium_drink = Ingredient.create_with(unit: "one", stored_quantity: 100, ingredient_type: "material", low_threshold: 10, high_threshold: 70, cost: 10_000).find_or_create_by(name: "Medium Drink")

p "Creating products for suborders ..."

# p1
prod_coco_rice = Product.create_with(kind: "entry", active: true, price: 2_000).find_or_create_by(name: "Coco Rice")
prod_fish_bowl = Product.create_with(kind: "dish", active: true, price: 35_000).find_or_create_by(name: "Fish Bowl")
# coco_rice, fish_bowl, lemonade
# p2
prod_super_chicken_bowl = Product.create_with(kind: "dish", active: true, price: 50_000).find_or_create_by(name: "Super Chicken Bowl")
prod_lemonade = Product.create_with(kind: "beverage", active: true, price: 5_000).find_or_create_by(name: "Lemonade")
prod_large_bowl_pack = Product.create_with(kind: "packing", active: true, price: 1_000).find_or_create_by(name: "Large Bowl Packing")
prod_medium_drink_pack = Product.create_with(kind: "packing", active: true, price: 500).find_or_create_by(name: "Medium Drink Packing")
# super_chicken_bowl, lemonade, included_in_order -> large_bowl_packing, medium_drink_packing
# p3
prod_super_fish_bowl = Product.create_with(kind: "dish", active: true, price: 50_000).find_or_create_by(name: "Super Fish Bowl")
# super_fish_bowl, soda, large_bowl_packing
# p4
prod_white_rice = Product.create_with(kind: "entry", active: true, price: 1_000).find_or_create_by(name: "White Rice")
prod_bitter_sweet_chicken_bowl = Product.create_with(kind: "dish", active: true, price: 35_000).find_or_create_by(name: "Bitter Sweet Chicken Bowl")
# rice, bitter_sweet_chicken_bowl, lemonade
# p5
prod_rice_with_chicken = Product.create_with(kind: "dish", active: true, price: 35_000).find_or_create_by(name: "Rice with Chicken")
prod_tiramisu = Product.create_with(kind: "dessert", active: true, price: 4_000).find_or_create_by(name: "Tiramisu")
prod_soda = Product.create_with(kind: "beverage", active: true, price: 5_000).find_or_create_by(name: "Soda")
# rice_with_chicken, tiramisu_dessert, soda
# p6
prod_spaguetti = Product.create_with(kind: "dish", active: true, price: 35_000).find_or_create_by(name: "Spaguetti")
# spaguetti, lemonade, large_bowl_packing, medium_drink_packing
# p8
prod_panela_lemonade = Product.create_with(kind: "beverage", active: true, price: 5_000).find_or_create_by(name: "Panela Lemonade")
# panela_lemonade
# p7
# super_chicken_bowl, lemonade, large_bowl_packing, medium_drink_packing

p "Creating recipes for suborders ..."

recip_magic_sauce_ingredient = Recipe.create_with(ingredient: ingred_magic_sauce, status: "approved").find_or_create_by(name: "Recipe for Magic Sauce")
recip_super_chicken_bowl = Recipe.create_with(product: prod_super_chicken_bowl, status: "approved").find_or_create_by(name: "Recipe for Super Chicken Bowl")
recip_lemonade = Recipe.create_with(product: prod_lemonade, status: "approved").find_or_create_by(name: "Recipe for Lemonade")
recip_large_bowl_pack = Recipe.create_with(product: prod_large_bowl_pack, status: "approved").find_or_create_by(name: "Recipe for Large Bowl Packing")
recip_medium_drink_pack = Recipe.create_with(product: prod_medium_drink_pack, status: "approved").find_or_create_by(name: "Recipe for Medium Drink Packing")
recip_coco_rice = Recipe.create_with(product: prod_coco_rice, status: "approved").find_or_create_by(name: "Recipe for Coco Rice")
recip_fish_bowl = Recipe.create_with(product: prod_fish_bowl, status: "approved").find_or_create_by(name: "Recipe for Fish Bowl")
recip_white_rice = Recipe.create_with(product: prod_white_rice, status: "approved").find_or_create_by(name: "Recipe for White Rice")
recip_bitter_sweet_chicken_bowl = Recipe.create_with(product: prod_bitter_sweet_chicken_bowl, status: "approved").find_or_create_by(name: "Recipe for Fish Bowl")
recip_rice_with_chicken = Recipe.create_with(product: prod_rice_with_chicken, status: "approved").find_or_create_by(name: "Recipe for Rice with Chicken")
recip_tiramisu = Recipe.create_with(product: prod_tiramisu, status: "approved").find_or_create_by(name: "Recipe for Tiramisu")
recip_soda = Recipe.create_with(product: prod_soda, status: "approved").find_or_create_by(name: "Recipe for Soda")
recip_spaguetti = Recipe.create_with(product: prod_spaguetti, status: "approved").find_or_create_by(name: "Recipe for Spaguetti")
recip_panela_lemonade = Recipe.create_with(product: prod_panela_lemonade, status: "approved").find_or_create_by(name: "Recipe for Panela Lemonade")
recip_super_fish_bowl = Recipe.create_with(product: prod_super_fish_bowl, status: "approved").find_or_create_by(name: "Recipe for Super Fish Bowl")

p "Creating ingredient_recipes for suborders ..."

# Magic Sauce
IngredientRecipe.create(ingredient: ingred_soy, recipe: recip_magic_sauce_ingredient, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_water_tap, recipe: recip_magic_sauce_ingredient, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_tomato_sauce, recipe: recip_magic_sauce_ingredient, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_lemon_juice, recipe: recip_magic_sauce_ingredient, required_quantity: 10)
# Super Chicken Bowl
IngredientRecipe.create(ingredient: ingred_magic_sauce, recipe: recip_super_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_olive_oil, recipe: recip_super_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_ocean_salt, recipe: recip_super_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_oregano, recipe: recip_super_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_chicken, recipe: recip_super_chicken_bowl, required_quantity: 100)
# Lemonade
IngredientRecipe.create(ingredient: ingred_lemon, recipe: recip_lemonade, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_sugar, recipe: recip_lemonade, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_sparkling_water, recipe: recip_lemonade, required_quantity: 10)
# Packing
IngredientRecipe.create(ingredient: ingred_large_bowl, recipe: recip_large_bowl_pack, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_medium_drink, recipe: recip_medium_drink_pack, required_quantity: 10)
# Coco Rice
IngredientRecipe.create(ingredient: ingred_olive_oil, recipe: recip_coco_rice, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_coconut, recipe: recip_coco_rice, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_rice, recipe: recip_coco_rice, required_quantity: 10)
# Fish Bowl
IngredientRecipe.create(ingredient: ingred_magic_sauce, recipe: recip_fish_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_olive_oil, recipe: recip_fish_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_ocean_salt, recipe: recip_fish_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_oregano, recipe: recip_fish_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_fish, recipe: recip_fish_bowl, required_quantity: 50)
# White Rice
IngredientRecipe.create(ingredient: ingred_olive_oil, recipe: recip_white_rice, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_rice, recipe: recip_white_rice, required_quantity: 10)
# Bitter Sweet Chicken Bowl
IngredientRecipe.create(ingredient: ingred_magic_sauce, recipe: recip_bitter_sweet_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_olive_oil, recipe: recip_bitter_sweet_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_ocean_salt, recipe: recip_bitter_sweet_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_oregano, recipe: recip_bitter_sweet_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_lemon_juice, recipe: recip_bitter_sweet_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_sugar, recipe: recip_bitter_sweet_chicken_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_chicken, recipe: recip_bitter_sweet_chicken_bowl, required_quantity: 50)
# Rice with Chicken
IngredientRecipe.create(ingredient: ingred_olive_oil, recipe: recip_rice_with_chicken, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_rice, recipe: recip_rice_with_chicken, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_chicken, recipe: recip_rice_with_chicken, required_quantity: 50)
IngredientRecipe.create(ingredient: ingred_tomato_sauce, recipe: recip_rice_with_chicken, required_quantity: 10)
# Tiramisu
IngredientRecipe.create(ingredient: ingred_tiramisu, recipe: recip_tiramisu, required_quantity: 1)
# Soda
IngredientRecipe.create(ingredient: ingred_soda, recipe: recip_soda, required_quantity: 1)
# Spaguetti
IngredientRecipe.create(ingredient: ingred_water_tap, recipe: recip_spaguetti, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_olive_oil, recipe: recip_spaguetti, required_quantity: 2)
IngredientRecipe.create(ingredient: ingred_pasta, recipe: recip_spaguetti, required_quantity: 10)
# Panela Lemonade
IngredientRecipe.create(ingredient: ingred_water_tap, recipe: recip_panela_lemonade, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_lemon, recipe: recip_panela_lemonade, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_panela, recipe: recip_panela_lemonade, required_quantity: 10)
# Super Fish Bowl
IngredientRecipe.create(ingredient: ingred_magic_sauce, recipe: recip_super_fish_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_olive_oil, recipe: recip_super_fish_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_ocean_salt, recipe: recip_super_fish_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_oregano, recipe: recip_super_fish_bowl, required_quantity: 10)
IngredientRecipe.create(ingredient: ingred_fish, recipe: recip_super_fish_bowl, required_quantity: 100)

p "Creating sell_orders ..."

allocation_one = Allocation.active.desk.first
allocation_two = Allocation.active.desk.second
allocation_delivery = Allocation.active.delivery.first
allocation_takeout = Allocation.where(name: "Takeout").first

sell_order1 = SellOrder.create(allocation: allocation_one, payment_type: "card", status: "closed")
sell_order2 = SellOrder.create(allocation: allocation_delivery, payment_type: "cash", status: "delivering")
sell_order3 = SellOrder.create(allocation: allocation_takeout, status: "packed") # Transfer
sell_order4 = SellOrder.create(allocation: allocation_one) # Cash
sell_order5 = SellOrder.create(allocation: allocation_two) # Transfer
sell_order6 = SellOrder.create(allocation: allocation_delivery, payment_type: "cash")
sell_order7 = SellOrder.create(allocation: allocation_takeout) # Transfer

p "Creating suborders ..."

order1 = Order.create(sell_order: sell_order1, status: "completed")
order2 = Order.create(sell_order: sell_order2, status: "packed")
order3 = Order.create(sell_order: sell_order3, status: "packed")
order4 = Order.create(sell_order: sell_order4, status: "completed")
order5 = Order.create(sell_order: sell_order5, status: "processing")
order6 = Order.create(sell_order: sell_order6, status: "processing")
order7 = Order.create(sell_order: sell_order7, status: "processing")
order8 = Order.create(sell_order: sell_order4)

p "Creating order_products for suborders ..."

OrderProduct.create(order: order1, status: "completed", product: prod_coco_rice, quantity: 1)
OrderProduct.create(order: order1, status: "completed", product: prod_fish_bowl, quantity: 1)
OrderProduct.create(order: order1, status: "completed", product: prod_lemonade, quantity: 1)

OrderProduct.create(order: order2, status: "completed", product: prod_super_chicken_bowl, quantity: 1)
OrderProduct.create(order: order2, status: "completed", product: prod_lemonade, quantity: 1)
OrderProduct.create(order: order2, status: "completed", product: prod_large_bowl_pack, quantity: 1)
OrderProduct.create(order: order2, status: "completed", product: prod_medium_drink_pack, quantity: 1)

OrderProduct.create(order: order3, status: "completed", product: prod_super_fish_bowl, quantity: 1)
OrderProduct.create(order: order3, status: "completed", product: prod_soda, quantity: 1)
OrderProduct.create(order: order3, status: "completed", product: prod_large_bowl_pack, quantity: 1)

OrderProduct.create(order: order4, status: "completed", product: prod_bitter_sweet_chicken_bowl, quantity: 1)
OrderProduct.create(order: order4, status: "completed", product: prod_white_rice, quantity: 1)
OrderProduct.create(order: order4, status: "completed", product: prod_lemonade, quantity: 1)

OrderProduct.create(order: order5, status: "preparing", product: prod_soda, quantity: 1)
OrderProduct.create(order: order5, status: "preparing", product: prod_tiramisu, quantity: 1)
OrderProduct.create(order: order5, status: "preparing", product: prod_rice_with_chicken, quantity: 1)

OrderProduct.create(order: order6, status: "prepare", product: prod_lemonade, quantity: 1)
OrderProduct.create(order: order6, status: "prepare", product: prod_spaguetti, quantity: 1)
OrderProduct.create(order: order6, status: "prepare", product: prod_large_bowl_pack, quantity: 1)
OrderProduct.create(order: order6, status: "prepare", product: prod_medium_drink_pack, quantity: 1)

OrderProduct.create(order: order7, status: "prepare", product: prod_super_chicken_bowl, quantity: 1)
OrderProduct.create(order: order7, status: "prepare", product: prod_lemonade, quantity: 1)
OrderProduct.create(order: order7, status: "prepare", product: prod_large_bowl_pack, quantity: 1)
OrderProduct.create(order: order7, status: "prepare", product: prod_medium_drink_pack, quantity: 1)

OrderProduct.create(order: order8, status: "prepare", product: prod_panela_lemonade, quantity: 1)

SellOrders::CreateBill.new(sell_order1).call
