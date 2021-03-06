# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.first_or_create(username: 'test_user', password: 'passw0rd', password_confirmation: 'passw0rd', email: 'blackhole@ledgr-app.com')
user.confirmed_at = Time.now
user.save!

10.times do |index|
  item = Item.where(name: "Item #{index}", user_id: user.id).first_or_create
  item.user = user
  item.save!
  
  rand(10).times do
    entry = Entry.new
    entry.item = item
    entry.quantity = rand(5)
    entry.datetime = DateTime.current
    entry.save!
  end
  
  category = Category.where(user_id: user.id, name: "Category #{index % 4}").first_or_create
  item.add_category(category)
end

time_since_last_entry_display_type = DisplayTypes::TimeSinceLastEntry.find_or_create_by(name: 'Time Since Last Entry')
time_since_last_entry_display_type.save!

time_between_entries_display_type = DisplayTypes::AverageTimeBetweenEntry.find_or_create_by(name: 'Time Between Entries')
time_between_entries_display_type.save!

5.times do |index|
  page = Page.where(title: "Page #{index}", user_id: user.id).first_or_create
  page.save!
  
  rand(12).times do |display_index|
    display = Display.where(page_id: page.id, title: "#{index} - #{display_index}", display_type_id: time_since_last_entry_display_type.id).first_or_create
    display.save!
  end
end
