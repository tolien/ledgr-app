class AddUniqueIndexOnItems < ActiveRecord::Migration
  def up
    add_index :items, [ :user_id, :name ], unique: true
  end

  def down
    remove_index :items, [ :user_id, :name ], unique: true
  end
end
