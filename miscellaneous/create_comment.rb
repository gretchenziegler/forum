require './lib/comment.rb'
require './lib/connection.rb'

category_id = 3
post_id = 3
user_name = ARGV[0].downcase
comment = ARGV[1]
date_added = Time.now

Comment.create({category_id: category_id, post_id: post_id, user_name: user_name, date_added: date_added, comment: comment})