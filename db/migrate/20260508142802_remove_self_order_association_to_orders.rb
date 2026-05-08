class RemoveSelfOrderAssociationToOrders < ActiveRecord::Migration[8.1]
  def change
    remove_index :orders, :parent_id
    remove_foreign_key :orders, :orders, column: :parent_id
    remove_column :orders, :parent_id, :bigint, null: true
  end
end
