class AddItemIdToEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :entries, :item_id, :integer
  end
end
