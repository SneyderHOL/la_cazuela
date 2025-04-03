class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :kind, null: false
      t.boolean :active, null: false

      t.timestamps
    end

    add_reference :recipes, :product, index: { unique: true }, foreign_key: true
  end
end
