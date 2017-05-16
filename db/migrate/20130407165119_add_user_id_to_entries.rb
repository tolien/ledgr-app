class AddUserIdToEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :entries, :user_id, :integer
    add_foreign_key "entries", "users", :name => "entries_user_id_fk", on_delete: :cascade
  end
end
