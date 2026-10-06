class AddCategoryToProducts < ActiveRecord::Migration[7.2]
  def change
    add_reference :products, :category, null: false, foreign_key: true
  end
end
