require './lib/post.rb'
require './lib/connection.rb'

category_id = 3
title = ARGV[0].downcase
content = ARGV[1]
user_name = ARGV[2].downcase
date_added = Time.now
expiration_date = Date.new(2014,12,22)
upvotes = 0
downvotes = 0
vote_total = 0


# "Michonne will kick some ass, obviously! <img src='http://the-walkingdead.com/wp-content/uploads/2014/11/Top-5-Michonne-Moments.jpg'>"

# "Maggie is going to exact some serious revenge after what happened to Beth. <img src='http://img1.wikia.nocookie.net/__cb20121122233534/walkingdead/images/8/8b/MaggieFB.jpg'>"

# "Daryl and Carol are gonna HOOK UP! <img src='http://media.comicbook.com/wp-content/uploads/2013/09/the-walking-dead-season-4-daryl-carol.jpg'>"

Post.create({category_id: category_id, title: title, content: content, user_name: user_name, date_added: date_added, expiration_date: expiration_date, upvotes: upvotes, downvotes: downvotes, vote_total: vote_total})