class RemoveUserIdFromEntries < ActiveRecord::Migration
  def up
    remove_foreign_key "entries", :name => "entries_user_id_fk"
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
