class AddUniqueIndexOnUsernames < ActiveRecord::Migration[5.0]
  def up
    add_index :users, :username, :unique => true
  end

  def down
    remove_index :users, :username
  end
end
