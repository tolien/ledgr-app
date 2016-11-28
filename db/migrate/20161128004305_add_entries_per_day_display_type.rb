class AddEntriesPerDayDisplayType < ActiveRecord::Migration[5.0]
  def change
    display_type = DisplayTypes::EntriesPerDay.find_or_create_by(name: 'Entries per Day')
    display_type.save!
  end
end
