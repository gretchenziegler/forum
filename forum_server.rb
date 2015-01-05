require "./lib/connection.rb"
require "./lib/category.rb"
require "./lib/comment.rb"
require "./lib/post.rb"
require "./lib/subscription.rb"
require "sinatra"
require "pry"
require "mustache"
require "sinatra/reloader"
require "will_paginate"
require "will_paginate/active_record"
require "will_paginate/array"
require "twilio-ruby"
require "sendgrid-ruby"
require "redcarpet"

# view index

get "/" do
	categories = Category.all.to_ary
	index = File.read("./views/index.html")
	Mustache.render(index, categories: categories)
end

# view information about a specific category

get "/categories/:id/:page" do
	category = Category.find(params[:id])
	posts = category.posts
	pagination = posts.paginate(:page => params[:page], :per_page => 10).to_ary
	current_page = params[:page]
	date = category.date_added.strftime("%m/%d/%Y")
	next_page = pagination.next_page
	previous_page = pagination.previous_page
	category_view = File.read("./views/category_view.html")
	Mustache.render(category_view, category: category, pagination: pagination, next_page: next_page, previous_page: previous_page, current_page: current_page, date: date)
end

# create a new category with description

post "/categories" do
	title = params["title"].downcase
	description = params["description"].downcase
	user_name = params["user_name"].downcase
	date_added = Time.now
	upvotes = 0
	downvotes = 0
	vote_total = 0

	new_category = Category.create({title: title, description: description, user_name: user_name, date_added: date_added, upvotes: upvotes, downvotes: downvotes, vote_total: vote_total})

	id = new_category.id

	redirect "/categories/#{id}/1"
end

# delete a post-less category

delete "/categories/:id" do
	category = Category.find(params[:id])
	category.destroy
		
	redirect "/"
end

# view add post form

get "/:title/posts" do
	category = Category.find_by(title: params[:title])
	new_post = File.read("./views/new_post.html")
	Mustache.render(new_post, category: category)
end

# create a new forum post within a category

post "/:title/posts" do
	category = Category.find_by(title: params[:title])

	category_id = category.id

	user_name = params["user_name"].downcase
	title = params["post_title"].downcase
	content = params["content"].downcase
	date_added = Time.now
	expiration_date = params["expiration_date"]
	upvotes = 0
	downvotes = 0
	vote_total = 0

	new_post = Post.create({category_id: category_id, title: title, content: content, user_name: user_name, date_added: date_added, expiration_date: expiration_date, upvotes: upvotes, downvotes: downvotes, vote_total: vote_total})

	id = new_post.id

	subscribers = category.subscriptions

	numbers = subscribers.map {|subscriber| subscriber[:phone]}
	numbers.each do |number|
		account_sid = 'AC6304fd30e4c5e09c62858029e1a1c49c'
		auth_token = '5eb57f166033dfa5036659332158657b'
		@client = Twilio::REST::Client.new account_sid, auth_token
		message = @client.account.messages.create(
		:body => "Someone has updated #{params[:title]}! Whatchu think about that?",
		:to => number,
		:from => '+12035280914'
		)
		puts message.sid
	end

	emails = subscribers.map {|subscriber| subscriber[:email]}
	emails.each do |email|
		client = SendGrid::Client.new(api_user: 'gretchenziegler', api_key: '8DinosaurCupcakes')
		client.send(SendGrid::Mail.new(to: email, from: 'gretchenziegler@gmail.com', subject: 'Whatchu think about this?', text: 'Someone has updated your subscribed category! Go check it out and add whatchu think!', html: '<h1>Someone has updated your subscribed category!</h1><br><p>Go check it out and add whatchu think!</p>'))
	end

	redirect "/posts/#{id}"
end

# view a specific post and its information

get "/posts/:id" do
	post = Post.find(params[:id])
	category_id = post.category_id
	category = Category.find(category_id)
	comments = Comment.where(post_id: params[:id]).to_ary

	post_date = post.date_added.strftime("%m/%d/%Y")

	renderer = Redcarpet::Render::HTML.new
  markdown = Redcarpet::Markdown.new(renderer)
	rendered_content = markdown.render(post.content)

	now = Date.today
	if post.expiration_date == nil
		expired = false
	elsif post.expiration_date - now <= 0
		expired = true
	else 
		expired = false
	end

	post_view = File.read("./views/post_view.html")
	Mustache.render(post_view, post: post, category: category, comments: comments, rendered_content: rendered_content, expired: expired, post_date: post_date)
end

# add a comment to a post

post "/posts/:title/comments" do
	post = Post.find_by(title: params[:title])
	
	post_id = post.id
	category_id = post.category_id
	date_added = Time.now.strftime("%m/%d/%Y")
	user_name = params["user_name"]
	comment = params["comment"]
	upvotes = 0
	downvotes = 0
	vote_total = 0
	
	Comment.create({category_id: category_id, post_id: post_id, user_name: user_name, date_added: date_added, comment: comment, upvotes: upvotes, downvotes: downvotes, vote_total: vote_total})
	
	subscribers = post.subscriptions
	
	numbers = subscribers.map {|subscriber| subscriber[:phone]}
	numbers.each do |number|
		account_sid = 'AC6304fd30e4c5e09c62858029e1a1c49c'
		auth_token = '5eb57f166033dfa5036659332158657b'
		@client = Twilio::REST::Client.new account_sid, auth_token
		message = @client.account.messages.create(
		:body => "Someone has updated #{params[:title]}! Whatchu think about that?",
		:to => number,
		:from => '+12035280914'
		)
		puts message.sid
	end

	emails = subscribers.map {|subscriber| subscriber[:email]}
	emails.each do |email|
		client = SendGrid::Client.new(api_user: 'gretchenziegler', api_key: '8DinosaurCupcakes')
		client.send(SendGrid::Mail.new(to: email, from: 'gretchenziegler@gmail.com', subject: 'Whatchu think about this?', text: 'Someone has updated your subscribed post! Go check it out and add whatchu think!', html: '<h1>Someone has updated your subscribed post!</h1><br><p>Go check it out and add whatchu think!</p>'))
	end
	redirect "/posts/#{post_id}"
end

# view category subscription form

get "/subscriptions/categories/:id" do
	category = Category.find(params[:id])
	subscription_view = File.read("./views/subscription_view.html")

	Mustache.render(subscription_view, category: category)
end

# view post subscription form

get "/subscriptions/posts/:id" do
	post = Post.find(params[:id])
	subscription_view = File.read("./views/subscription_view.html")

	Mustache.render(subscription_view, post: post)
end

# subscribe to a post

post "/subscriptions/posts/:id" do
	post = Post.find(params[:id])

	post_id = post.id
	category_id = post.category_id
	first_name = params["first_name"]
	last_name = params["last_name"]
	email = params["email"]
	phone = params["phone"]

	if email == nil || phone == nil
		redirect "/errors/missing"
	end

	Subscription.create({post_id: post_id, category_id: category_id, first_name: first_name, last_name: last_name, email: email, phone: phone})

	redirect "/posts/#{post_id}"
end

# display error for missing phone or email

get "/errors/missing" do
	File.read("/views/no_contact_error.html")
end

# subscribe to a category

post "/subscriptions/categories/:id" do
	category = Category.find(params[:id])

	category_id = category.id
	first_name = params["first_name"]
	last_name = params["last_name"]
	email = params["email"]
	phone = params["phone"]

	Subscription.create({category_id: category_id, first_name: first_name, last_name: last_name, email: email, phone: phone})

	redirect "/categories/#{category_id}"
end

# upvote a category

get "/categories/:id/:page/upvote" do
	category = Category.find(params[:id])
	category.upvotes +=1
	category.vote_total += 1
	category.save
	redirect "/categories/#{params[:id]}/#{params[:page]}"
end

# downvote a category

get "/categories/:id/:page/downvote" do
	category = Category.find(params[:id])
	category.downvotes +=1
	category.vote_total -= 1
	category.save
	redirect "/categories/#{params[:id]}/#{params[:page]}"
end

# upvote a post

get "/posts/:id/upvote" do
	post = Post.find(params[:id])
	post.upvotes +=1
	post.vote_total += 1
	post.save
	redirect "/posts/#{params[:id]}"
end

# downvote a post

get "/posts/:id/downvote" do
	post = Post.find(params[:id])
	post.downvotes +=1
	post.vote_total -= 1
	post.save
	redirect "/posts/#{params[:id]}"
end

# upvote a comment

get "/comments/:id/upvote" do
	comment = Comment.find(params[:id])
	post_id = comment.post_id
	comment.upvotes +=1
	comment.vote_total += 1
	comment.save
	redirect "/posts/#{post_id}"
end

# downvote a comment

get "/comments/:id/downvote" do
	comment = Comment.find(params[:id])
	post_id = comment.post_id
	comment.downvotes +=1
	comment.vote_total -= 1
	comment.save
	redirect "/posts/#{post_id}"
end