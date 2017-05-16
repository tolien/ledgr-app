class AddUniqueIndexOnCategories < ActiveRecord::Migration[5.0]
  def change
    add_index :categories, [:name, :user_id], unique: true
  end
end
