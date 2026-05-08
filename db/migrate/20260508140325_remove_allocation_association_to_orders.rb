class RemoveAllocationAssociationToOrders < ActiveRecord::Migration[8.1]
  def change
    remove_index :orders, :allocation_id
    remove_foreign_key :orders, :allocations, column: :allocation_id
    remove_column :orders, :allocation_id, :bigint, null: false
  end
end
