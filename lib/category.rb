require "active_record"

class Category < ActiveRecord::Base
	has_many :posts
	has_many :subscriptions
end