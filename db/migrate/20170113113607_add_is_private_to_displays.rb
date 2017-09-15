class AddIsPrivateToDisplays < ActiveRecord::Migration[5.0]
  def change
    add_column :displays, :is_private, :boolean, default: false
  end
end
