class AddDatetimeIndexOnEntries < ActiveRecord::Migration
  def up
    add_index :entries, :datetime
  end

  def down
    remove_index :entries, :datetime
  end
end
