# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_14_133814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "allocations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "kind", null: false
    t.string "status", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ingredient_recipes", force: :cascade do |t|
    t.bigint "ingredient_id", null: false
    t.bigint "recipe_id", null: false
    t.integer "required_quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id", "recipe_id"], name: "index_ingredient_recipes_on_ingredient_id_and_recipe_id", unique: true
    t.index ["ingredient_id"], name: "index_ingredient_recipes_on_ingredient_id"
    t.index ["recipe_id"], name: "index_ingredient_recipes_on_recipe_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.integer "stored_quantity", null: false
    t.integer "unit", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ingredient_type", default: "regular", null: false
    t.integer "low_threshold", default: 0, null: false
    t.integer "high_threshold", default: 0, null: false
  end

  create_table "inventory_transactions", force: :cascade do |t|
    t.bigint "ingredient_id", null: false
    t.integer "quantity", null: false
    t.integer "kind", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "error_message"
    t.index ["ingredient_id"], name: "index_inventory_transactions_on_ingredient_id"
  end

  create_table "order_products", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.bigint "recipe_id"
    t.string "status", null: false
    t.integer "quantity", null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["product_id"], name: "index_order_products_on_product_id"
    t.index ["recipe_id"], name: "index_order_products_on_recipe_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.bigint "allocation_id", null: false
    t.index ["allocation_id"], name: "index_orders_on_allocation_id"
    t.index ["parent_id"], name: "index_orders_on_parent_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.integer "kind", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipes", force: :cascade do |t|
    t.string "name", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_id"
    t.bigint "ingredient_id"
    t.index ["ingredient_id"], name: "index_recipes_on_ingredient_id", unique: true
    t.index ["product_id"], name: "index_recipes_on_product_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "role"
    t.string "name"
    t.string "nickname"
    t.boolean "active", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "ingredient_recipes", "ingredients"
  add_foreign_key "ingredient_recipes", "recipes"
  add_foreign_key "inventory_transactions", "ingredients"
  add_foreign_key "order_products", "orders"
  add_foreign_key "order_products", "products"
  add_foreign_key "orders", "allocations"
  add_foreign_key "orders", "orders", column: "parent_id"
  add_foreign_key "recipes", "ingredients"
  add_foreign_key "recipes", "products"
end
