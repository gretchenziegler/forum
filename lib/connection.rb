require "active_record"

ActiveRecord::Base.establish_connection({
	:adapter => "postgresql",
	:host => "localhost",
	:username => "gretchenziegler",
	:database => "forum"
})

ActiveRecord::Base.logger = Logger.new(STDOUT)