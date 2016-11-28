class AddDayAverageDisplayType < ActiveRecord::Migration[5.0]
  def change
    display_type = DisplayTypes::DayAverage.find_or_create_by(name: 'Day Average')
    display_type.save!
  end
end
