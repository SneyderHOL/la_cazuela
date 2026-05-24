class CreateFunds < ActiveRecord::Migration[8.1]
  def change
    create_table :funds do |t|
      t.string :detail, null: false
      t.integer :amount, null: false
      t.boolean :is_deposit, null: false
      t.date :transaction_date, null: false

      t.timestamps
    end

    add_index :funds, :transaction_date
  end
end
