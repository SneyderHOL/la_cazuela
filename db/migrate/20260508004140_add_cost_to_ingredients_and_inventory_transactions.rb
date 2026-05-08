class AddCostToIngredientsAndInventoryTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :ingredients, :cost, :integer, null: false, default: 0
    add_column :inventory_transactions, :cost, :integer, null: false, default: 0
  end
end
