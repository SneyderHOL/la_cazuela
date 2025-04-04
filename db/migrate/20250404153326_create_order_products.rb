class CreateOrderProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :order_products do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :recipe
      t.string :status, null: false
      t.integer :quantity, null: false
      t.string :note

      t.timestamps
    end
  end
end
