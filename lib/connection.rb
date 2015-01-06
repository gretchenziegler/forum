require "active_record"

# ActiveRecord::Base.establish_connection('postgresql://' + ENV["DB_INFO"] + '@127.0.0.1/forum')

ActiveRecord::Base.establish_connection({
	:adapter => "postgresql",
	:host => "localhost",
	:username => "gretchenziegler",
	:database => "forum"
})

ActiveRecord::Base.logger = Logger.new(STDOUT)