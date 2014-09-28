class AddUniqueIndexOnCategories < ActiveRecord::Migration
  def change
    add_index :categories, [:name, :user_id]
  end
end
