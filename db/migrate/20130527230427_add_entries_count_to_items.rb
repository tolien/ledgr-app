class AddEntriesCountToItems < ActiveRecord::Migration
  def up
    add_column :items, :entries_count, :integer
    
    Item.reset_column_information
    Item.all.each do |item|
      Item.update_counters item.id, entries_count: item.entries.length
    end
  end
  
  def down
    remove_column :items, :entries_count
  end
end
