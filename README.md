# whatchu think about?

## a forum for anything and everything.

**whatchu think about?** is a completely user-generated forum. you want to post about bunnies? go ahead. you have a thought about the use of symbolism in post-war russian literature? share it with the world. you're dying to convince others that the rapture is right around the corner, and the only way to survive it is to eat your own arms? knock yourself out; no one's going to stop you!

## gems

#### activerecord

activerecord allows users to create and store data within a database, and manipulate relationships between that data; all topics, posts, and comments within **whatchu think about?** are stored and connected via activerecord.

#### sinatra

sinatra is a domain-specific language that helps build ruby applications. **whatchu think about?** uses sinatra to define routes within the site.

#### mustache

mustache is a great tool for creating templates. it works pretty seamlessly with html, sinatra, and activerecord to display data from within a database and render it as html. it's what makes **whatchu think about?** look so darn fancy!

#### redcarpet

redcarpet is a ruby library for markdown processing. **whatchu think about?** uses redcarpet to allow users to write their posts in markdown and have it rendered as html.

#### will_paginate

will_paginate does what it sounds like it does: it splits elements into pages! **whatchu think about?** uses will_paginate to break down category pages so that they only display ten posts at a time.

#### twilio and sendgrid

if you want to reach out to your user base, twilio and sendgrid will help with that! taking a user's number and email as input, twilio will send any sms message you like, and sendgrid will send an html email. if you subscribe to a post or topic on **whatchu think about?**, you'll receive sms and email updates when someone posts a new thought!

## download whatchu think about?

you can run **whatchu think about?** on your localhost! which is kind of redonk, but hey, it's your time and happiness, so have at it! 

here's how:

1. make a directory in terminal where you want to keep the sweet, sweet forum files.

2. while in that directory, run this command: `git init`

3. then run this command: `git clone https://github.com/gretchenziegler/forum.git`

4. and then this one: `git pull origin master`

5. in lib/connection.rb, comment out the current connection and comment in the one below it. don't forget to change the username to your own username!

6. now you gotta create an empty database. such fun! go into psql and type the following stuff:

	- `CREATE DATABASE forum;`
	- `\c forum;`
	- `CREATE TABLE categories ( id serial primary key, title varchar(100), description text, user_name varchar(100), date_added timestamp, upvotes integer, downvotes integer, vote_total integer);`
	- `CREATE TABLE posts ( id serial primary key, category_id integer, title varchar(100), content text, user_name varchar(100), date_added timestamp, expiration_date date, upvotes integer, downvotes integer, vote_total integer);`
	- `CREATE TABLE comments ( id serial primary key, post_id integer, category_id integer, user_name varchar(100), comment text, date_added varchar(15), upvotes integer, downvotes integer, vote_total integer);`
	- `CREATE TABLE subscriptions ( id serial primary key, first_name varchar(100), last_name varchar(100), email text, phone text, category_id integer, post_id integer);`
	- `\q`

7. phew. now run: `ruby forum_server.rb`

8. in your browser window, type `127.0.0.1:4567`, and you will have your own empty **whatchu think about?** forum to play with. because who wouldn't want that?

![haters gonna hate](http://img4.wikia.nocookie.net/__cb20121027135359/adventuretimewithfinnandjake/images/2/20/Haters-gonna-hate-potatoes-gonna-potate.jpg)

## trello

check out the process of creating **whatchu think about?** (think wireframes, erds, user stories, and all that good stuff) [here](https://trello.com/b/V6XeCQel/forum).

## live url

see what others think and add your thoughts to [**whatchu think about?**](http://gretchenziegler.com)
