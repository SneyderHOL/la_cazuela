class CreateAllocations < ActiveRecord::Migration[8.0]
  def change
    create_table :allocations do |t|
      t.string :name, null: false
      t.integer :kind, null: false
      t.string :status, null: false
      t.boolean :active, null: false

      t.timestamps
    end

    add_reference :orders, :allocation, null: false, foreign_key: true
  end
end
