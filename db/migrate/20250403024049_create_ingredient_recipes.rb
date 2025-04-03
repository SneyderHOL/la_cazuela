class CreateIngredientRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredient_recipes do |t|
      t.references :ingredient, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.integer :required_quantity, null: false

      t.timestamps
    end
    add_index(:ingredient_recipes, [ :ingredient_id, :recipe_id ], unique: true)
  end
end
