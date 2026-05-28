class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false, index: { unique: true }
      t.boolean :active, null: false, default: false
      t.string :ancestry, collation: 'C', null: false
      t.index :ancestry

      t.timestamps
    end
  end
end
