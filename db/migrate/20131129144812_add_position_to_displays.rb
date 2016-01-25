class AddPositionToDisplays < ActiveRecord::Migration
  def change
    add_column :displays, :position, :integer
  end
end
