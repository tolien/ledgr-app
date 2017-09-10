class RemoveDisplayOffsets < ActiveRecord::Migration[5.1]
  def change
    remove_column :displays, :start_offset_days
    remove_column :displays, :end_offset_days
  end
end
