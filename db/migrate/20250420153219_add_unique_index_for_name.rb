class AddUniqueIndexForName < ActiveRecord::Migration[8.0]
  def change
    add_index :products, :name, unique: true
    add_index :ingredients, :name, unique: true
    add_index :allocations, :name, unique: true
    add_index :recipes, :name, unique: true
  end
end
