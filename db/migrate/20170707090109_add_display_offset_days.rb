class AddDisplayOffsetDays < ActiveRecord::Migration[5.1]
  def change
    add_column :displays, :start_days_from_now, :integer
  end
end
