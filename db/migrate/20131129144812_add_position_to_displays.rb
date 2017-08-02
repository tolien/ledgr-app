class AddPositionToDisplays < ActiveRecord::Migration[5.0]
  def change
    add_column :displays, :position, :integer
  end
end
