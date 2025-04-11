class AddIngredientToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_reference :recipes, :ingredient, index: { unique: true }, foreign_key: true
  end
end
