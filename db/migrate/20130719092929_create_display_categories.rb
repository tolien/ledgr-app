class CreateDisplayCategories < ActiveRecord::Migration
  def change
    create_table :display_categories do |t|
      t.integer :category_id, null: false
      t.integer :display_id, null: false

      t.timestamps null: :false
    end
    
    add_index :display_categories, [:category_id, :display_id], unique: true
  end
end
