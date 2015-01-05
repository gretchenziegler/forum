CREATE TABLE categories ( id serial primary key, title varchar(100), description text, user_name varchar(100), date_added timestamp, upvotes integer, downvotes integer, vote_total integer);

CREATE TABLE posts ( id serial primary key, category_id integer, title varchar(100), content text, user_name varchar(100), date_added timestamp, expiration_date date, upvotes integer, downvotes integer, vote_total integer);

CREATE TABLE comments ( id serial primary key, post_id integer, category_id integer, user_name varchar(100), comment text, date_added varchar(15), upvotes integer, downvotes integer, vote_total integer);

CREATE TABLE subscriptions ( id serial primary key, first_name varchar(100), last_name varchar(100), email text, phone text, category_id integer, post_id integer);