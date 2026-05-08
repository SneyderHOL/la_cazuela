class RemoveOrderAssociationForBills < ActiveRecord::Migration[8.1]
  def change
    remove_index :bills, :order_id
    remove_foreign_key :bills, :orders, column: :order_id
    remove_column :bills, :order_id, :bigint, null: false
  end
end
