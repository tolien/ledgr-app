class AddItemIdToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :item_id, :integer
  end
end
