class RemoveInventoriedAttributeToOrderProducts < ActiveRecord::Migration[8.1]
  def change
    remove_column :order_products, :inventoried, :boolean, null: true
  end
end
