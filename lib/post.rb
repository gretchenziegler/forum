require "active_record"

class Post < ActiveRecord::Base
	belongs_to :category
	has_many :subscriptions
end