class CreateSellOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :sell_orders do |t|
      t.references :allocation, null: false, foreign_key: true
      t.string :status, null: false
      t.string :payment_type, null: true
      t.integer :total, null: true
      t.integer :cash_pay, null: true
      t.integer :cash_change, null: true

      t.timestamps
    end

    add_reference :orders, :sell_order, null: false, foreign_key: true
    add_reference :bills, :sell_order, null: false, foreign_key: true
  end
end
