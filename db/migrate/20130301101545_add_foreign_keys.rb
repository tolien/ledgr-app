class AddForeignKeys < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key "categories", "users", :name => "categories_user_id_fk", on_delete: :cascade
    add_foreign_key "entries", "items", :name => "entries_item_id_fk", on_delete: :cascade
    add_foreign_key "items", "users", :name => "items_user_id_fk", on_delete: :cascade
  end
end
