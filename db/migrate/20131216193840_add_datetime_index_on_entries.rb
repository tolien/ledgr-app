class AddDatetimeIndexOnEntries < ActiveRecord::Migration[5.0]
  def up
    add_index :entries, :datetime
  end

  def down
    remove_index :entries, :datetime
  end
end
