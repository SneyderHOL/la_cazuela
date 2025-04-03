class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.integer :stored_quantity, null: false
      t.integer :unit, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
