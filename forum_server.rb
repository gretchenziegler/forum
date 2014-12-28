require "./lib/connection.rb"
require "./lib/category.rb"
require "./lib/comment.rb"
require "./lib/post.rb"
require "./lib/subscription.rb"
require "sinatra"
require "pry"
require "mustache"
require "sinatra/reloader"
require "redcarpet"
require "will_paginate"
require "will_paginate/active_record"

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

	next_page = pagination.next_page
	previous_page = pagination.previous_page

	category_view = File.read("./views/category_view.html")
	Mustache.render(category_view, category: category, pagination: pagination, next_page: next_page, previous_page: previous_page, current_page: current_page)
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

	user_name = params["user_name"]
	title = params["post_title"]
	content = params["content"]
	date_added = Time.now
	expiration_date = params["expiration_date"]
	upvotes = 0
	downvotes = 0
	vote_total = 0

	new_post = Post.create({category_id: category_id, title: title, content: content, user_name: user_name, date_added: date_added, expiration_date: expiration_date, upvotes: upvotes, downvotes: downvotes, vote_total: vote_total})

	id = new_post.id

	redirect "/posts/#{id}"
end

# view a specific post and its information

get "/posts/:id" do
	post = Post.find(params[:id])
	category_id = post.category_id
	category = Category.find(category_id)
	comments = Comment.where(post_id: params[:id]).to_ary

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
	Mustache.render(post_view, post: post, category: category, comments: comments, rendered_content: rendered_content, expired: expired)
end

# add a comment to a post

post "/posts/:title/comments" do
	post = Post.find_by(title: params[:title])
	
	post_id = post.id
	category_id = post.category_id
	date_added = Time.now
	user_name = params["user_name"]
	comment = params["comment"]

	Comment.create({category_id: category_id, post_id: post_id, user_name: user_name, date_added: date_added, comment: comment})

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

	Subscription.create({post_id: post_id, category_id: category_id, first_name: first_name, last_name: last_name, email: email, phone: phone})

	redirect "/posts/#{post_id}"
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