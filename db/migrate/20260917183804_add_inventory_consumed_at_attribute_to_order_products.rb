class AddInventoryConsumedAtAttributeToOrderProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :order_products, :inventory_consumed_at, :datetime, null: true
  end
end
