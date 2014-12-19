require './lib/subscription.rb'
require './lib/connection.rb'

category_id = 3
first_name = ARGV[0]
last_name = ARGV[1]
email = ARGV[2]
phone = ARGV[3]

Subscription.create({category_id: category_id, first_name: first_name, last_name: last_name, email: email, phone: phone})
