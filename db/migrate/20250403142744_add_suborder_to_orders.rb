class AddSuborderToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :parent_id, :bigint, null: true
    add_foreign_key :orders, :orders, column: :parent_id
    add_index :orders, :parent_id
  end
end
