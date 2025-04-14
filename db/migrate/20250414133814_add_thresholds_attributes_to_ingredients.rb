class AddThresholdsAttributesToIngredients < ActiveRecord::Migration[8.0]
  def change
    add_column :ingredients, :low_threshold, :integer, null: false, default: 0
    add_column :ingredients, :high_threshold, :integer, null: false, default: 0
  end
end
