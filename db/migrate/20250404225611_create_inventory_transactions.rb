class CreateInventoryTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_transactions do |t|
      t.references :ingredient, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :kind, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
