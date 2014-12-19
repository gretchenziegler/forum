require './lib/category.rb'
require './lib/connection.rb'

title = ARGV[0]
description = ARGV[1]
user_name = ARGV[2]
date_added = Time.now
upvotes = 0
downvotes = 0
vote_total = 0


Category.create({title: title, description: description, user_name: user_name, date_added: date_added, upvotes: upvotes, downvotes: downvotes, vote_total: vote_total})