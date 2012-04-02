require 'twitter'

class Tweet < ActiveRecord::Base
	has_many :notifications
	has_many :events, :through => :notifications

	attr_accessor :time_zone

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

	def small_profile_image
		profile_image.gsub /normal/, "mini"
	end

	def formatted_timestamp
		timestamp.in_time_zone(time_zone).strftime "%a %b %e %l:%M %P"
	end
end
