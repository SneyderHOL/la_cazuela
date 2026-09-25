class AddDirectionAttributeToInventoryTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :inventory_transactions, :direction, :string, null: false
  end
end
