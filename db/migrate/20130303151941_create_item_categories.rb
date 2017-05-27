class CreateItemCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :item_categories do |t|
      t.integer :item_id, null: false
      t.integer :category_id, null: false

      t.timestamps null: :false
    end
    
    add_index :item_categories, [:category_id, :item_id], unique: true
    add_foreign_key "item_categories", "categories", :name => "item_categories_category_id_fk", on_delete: :cascade
    add_foreign_key "item_categories", "items", :name => "item_categories_item_id_fk", on_delete: :cascade
  end
end
