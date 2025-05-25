class AddByAdminAttributeToInventoryTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :inventory_transactions, :by_admin, :boolean, null: false, default: false
  end
end
