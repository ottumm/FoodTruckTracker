require 'twitter'

class Tweet < ActiveRecord::Base
	has_many :notifications
	has_many :events, :through => :notifications

	attr_accessor :time_zone

	def url
		"http://twitter.com/#{user}/status/#{id}"
	end

	def profile_image_url
		if profile_image.nil?
			logger.debug "Fetching profile image url for #{user}"
			self.profile_image = Twitter.user(user).profile_image_url
			self.save
		end

		profile_image
	end

	def formatted_timestamp
		timestamp.in_time_zone(time_zone).strftime "%a %b %e %l:%M %P"
	end
end
