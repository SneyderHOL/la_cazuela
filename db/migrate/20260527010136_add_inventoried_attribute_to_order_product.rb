class AddInventoriedAttributeToOrderProduct < ActiveRecord::Migration[8.1]
  def change
    add_column :order_products, :inventoried, :boolean, null: true
  end
end
