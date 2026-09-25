class RemoveKindAttributeToInventoryTransactions < ActiveRecord::Migration[8.1]
  def change
    remove_column :inventory_transactions, :kind, :integer, null: false
  end
end
