class Tweet < ActiveRecord::Base
	include Comparable

	has_many :notifications
	has_many :events, :through => :notifications
	has_one :posting
	has_one :truck, :through => :posting

	def url
		"http://twitter.com/#{truck.name}/status/#{tweet_id}"
	end

	def formatted_timestamp
		timestamp.in_time_zone(truck.time_zone).strftime "%a %b %e %l:%M %P"
	end

	def <=> t
		self.tweet_id <=> t.tweet_id
	end
end
