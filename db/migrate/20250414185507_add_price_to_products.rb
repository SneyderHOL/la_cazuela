class AddPriceToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :price, :integer, null: false
    add_column :products, :detail, :string
  end
end
