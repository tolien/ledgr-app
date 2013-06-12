class AddUserIdToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :user_id, :integer
    add_foreign_key "entries", "users", :name => "entries_user_id_fk", dependent: :delete
  end
end
