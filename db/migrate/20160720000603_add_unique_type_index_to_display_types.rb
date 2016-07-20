class AddUniqueTypeIndexToDisplayTypes < ActiveRecord::Migration[5.0]
  def change
    add_index :display_types, :type, unique: true
  end
end
