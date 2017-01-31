class AddTotalDisplayType < ActiveRecord::Migration[5.0]
  def change
    display_type = DisplayTypes::Total.find_or_create_by(name: 'Total')
    display_type.save!
  end
end
