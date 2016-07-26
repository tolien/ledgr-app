class AddDefaultToEntriesCount < ActiveRecord::Migration[5.0]
  def change
    change_column_default :items, :entries_count, 0
  end
end
