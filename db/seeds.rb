# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin = User.create(email: 'admin@whopaid.us', first_name: 'Admin', last_name: '', password: 'administrator', role: :admin)

if Rails.env.development?
	# event1 = Event.create(name: 'Test Event #1', owner_id: admin.id)
	# user1 = User.create(email: 'user1@test.com', first_name: 'User', last_name: 'One', password: 'tester', role: :user)
	# user2 = User.create(email: 'user2@test.com', first_name: 'User', last_name: 'Two', password: 'tester', role: :user)
	# user3 = User.create(email: 'user3@test.com', first_name: 'User', last_name: 'Three', password: 'tester', role: :user)
	# Account.create(source_id: event1.id, source_type: 'Event', event_id: event1.id, name: 'Test Event #1')
	# Account.create(source_id: user1.id, source_type: 'User', event_id: event1.id, name: 'User One')
	# Account.create(source_id: user2.id, source_type: 'User', event_id: event1.id, name: 'User Two')
	# Account.create(source_id: user3.id, source_type: 'User', event_id: event1.id, name: 'User Three')
end