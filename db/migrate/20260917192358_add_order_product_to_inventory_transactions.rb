class AddOrderProductToInventoryTransactions < ActiveRecord::Migration[8.1]
  def change
    add_reference :inventory_transactions, :order_product, null: true, foreign_key: true
  end
end
