# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(username: 'test_user', password: 'passw0rd', password_confirmation: 'passw0rd', email: 'blackhole@ledgr-app.com')
user.confirmed_at = Time.now
user.save!

