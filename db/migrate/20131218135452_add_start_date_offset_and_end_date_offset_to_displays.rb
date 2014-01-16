class AddStartDateOffsetAndEndDateOffsetToDisplays < ActiveRecord::Migration
  def change
    add_column :displays, :start_offset_days, :integer
    add_column :displays, :end_offset_days, :integer
  end
end
