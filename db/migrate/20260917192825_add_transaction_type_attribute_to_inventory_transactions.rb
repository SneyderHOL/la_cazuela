class AddTransactionTypeAttributeToInventoryTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :inventory_transactions, :transaction_type, :string, null: false
  end
end
