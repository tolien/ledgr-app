class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "categories", "users", :name => "categories_user_id_fk", dependent: :delete
    add_foreign_key "entries", "items", :name => "entries_item_id_fk", dependent: :delete
    add_foreign_key "entries", "users", :name => "entries_user_id_fk", dependent: :delete
    add_foreign_key "item_categories", "categories", :name => "item_categories_category_id_fk", dependent: :delete
    add_foreign_key "item_categories", "items", :name => "item_categories_item_id_fk", dependent: :delete
    add_foreign_key "items", "users", :name => "items_user_id_fk", dependent: :delete
  end
end
