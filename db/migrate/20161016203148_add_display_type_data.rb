class AddDisplayTypeData < ActiveRecord::Migration[5.0]
  def change
    time_since_last_entry_display_type = DisplayTypes::TimeSinceLastEntry.find_or_create_by(name: 'Time Since Last Entry')
    time_since_last_entry_display_type.save!
    
    time_between_entries_display_type = DisplayTypes::AverageTimeBetweenEntry.find_or_create_by(name: 'Time Between Entries')
    time_between_entries_display_type.save!
  end  
end
