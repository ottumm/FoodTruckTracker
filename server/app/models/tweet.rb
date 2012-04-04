require 'twitter'

class Tweet < ActiveRecord::Base
	has_many :notifications
	has_many :events, :through => :notifications

	def url
		"http://twitter.com/#{user}/status/#{tweet_id}"
	end

	def profile_image
		if super.nil?
			logger.debug "Fetching profile image url for #{user}"
			update_attribute :profile_image, Twitter.user(user).profile_image_url
		end

		super
	end

	def time_zone
		if super.nil?
			logger.debug "Fetching time_zone for #{user}"
			update_attribute :time_zone, Twitter.user(user).time_zone
		end

		super
	end

	def formatted_timestamp
		timestamp.in_time_zone(time_zone).strftime "%a %b %e %l:%M %P"
	end
end
