class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "categories", "users", :name => "categories_user_id_fk", dependent: :delete
    add_foreign_key "entries", "items", :name => "entries_item_id_fk", dependent: :delete
    add_foreign_key "items", "users", :name => "items_user_id_fk", dependent: :delete
  end
end
