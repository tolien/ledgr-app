class AddItemIdIndexToEntries < ActiveRecord::Migration[5.2]
  def up
    add_index :entries, :item_id
  end

  def down
    remove_index :entries, :item_id
  end
end
