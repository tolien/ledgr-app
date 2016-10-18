class AddDisplayTypeData < ActiveRecord::Migration[5.0]
  def change
    time_since_last_entry_display_type = DisplayTypes::TimeSinceLastEntry.create(name: 'Time Since Last Entry')
    time_since_last_entry_display_type.save!
    
    time_between_entries_display_type = DisplayTypes::AverageTimeBetweenEntry.create(name: 'Time Between Entries')
    time_between_entries_display_type.save!
  end  
end
