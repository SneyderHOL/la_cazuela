class CreateBills < ActiveRecord::Migration[8.0]
  def change
    create_table :bills do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :total, null: false
      t.jsonb :detail

      t.timestamps
    end
  end
end
