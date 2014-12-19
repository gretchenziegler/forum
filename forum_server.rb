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

# view index

get "/" do
	categories = Category.all.to_ary
	index = File.read("./views/index.html")
	Mustache.render(index, categories: categories)
end

# view information about a specific category

get "/categories/:id" do
	category = Category.find(params[:id])
	posts = Post.where(category_id: params[:id]).to_ary
	category_view = File.read("./views/category_view.html")
	Mustache.render(category_view, category: category, posts: posts)
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

	redirect "/categories/#{id}"
end

# delete a post-less category

delete "/categories/:id" do
	category = Category.find(params[:id])
	category.destroy
		
	redirect "/"
end

# view add post form

get "/categories/:title/posts" do
	category = Category.find_by(title: params[:title])
	new_post = File.read("./views/new_post.html")
	Mustache.render(new_post, category: category)
end

# create a new forum post within a category

post "/categories/:title/posts" do
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

	# rendered_content = RedCarpet::Markdown.new(post.content)
	post_view = File.read("./views/post_view.html")
	Mustache.render(post_view, post: post, category: category, comments: comments)
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
