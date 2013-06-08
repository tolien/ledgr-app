class CreateItemCategories < ActiveRecord::Migration
  def change
    create_table :item_categories do |t|
      t.integer :item_id, null: false
      t.integer :category_id, null: false

      t.timestamps
    end
    
    add_index :item_categories, [:category_id, :item_id], unique: true
    add_foreign_key "item_categories", "categories", :name => "item_categories_category_id_fk", dependent: :delete
    add_foreign_key "item_categories", "items", :name => "item_categories_item_id_fk", dependent: :delete
  end
end
