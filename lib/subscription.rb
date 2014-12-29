require "active_record"

class Subscription < ActiveRecord::Base
	belongs_to :category
	belongs_to :post
end