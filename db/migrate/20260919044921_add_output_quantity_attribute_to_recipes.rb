class AddOutputQuantityAttributeToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :output_quantity, :integer, null: false, default: 1
  end
end
