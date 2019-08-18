class RemoveUserIdFromEntries < ActiveRecord::Migration[5.0]
  def up
    remove_foreign_key "entries", :users
    remove_column :entries, :user_id
    
  end

  def down
    add_column :entries, :user_id, :integer
    add_foreign_key "entries", "users", :name => "entries_user_id_fk"

    Entry.reset_column_information
    Entry.all.each do |entry|
      entry.update_attributes!(user_id: entry.item.user.id)
    end    
    
  end
end
