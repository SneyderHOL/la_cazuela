class AddErrorMessageAttributeToInventoryTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :inventory_transactions, :error_message, :string
  end
end
