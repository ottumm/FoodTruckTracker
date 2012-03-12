require 'haversine_distance'
require 'twitter'

class Event < ActiveRecord::Base
	attr_accessor :distance

	def self.find_today
		set_time_zone
		where(:start_time => (Time.now.beginning_of_day..Time.now.beginning_of_day + 1.day)).order :start_time
	end

	def self.find_nearby loc, range
		find_today.select do |event|
			event.distance = haversine_distance(loc, {:lat => event[:latitude], :long => event[:longitude]})
			event.distance < range
		end.sort {|a, b| a.distance <=> b.distance}
	end

	def google_maps_url
		"http://maps.google.com/maps?q=#{CGI::escape formatted_address}"
	end

	def formatted_start_time
		Event.set_time_zone
		start_time.strftime "%l:%M %P"
	end

	def formatted_created_at
		Event.set_time_zone
		created_at.strftime "%a %b %e %l:%M %P"
	end

	def formatted_distance
		if distance
			"%.1f km" % distance
		else
			"n/a"
		end
	end

	def tweet_url
		"http://twitter.com/#{name}/status/#{tweet_id}"
	end

	def profile_image_url
		if profile_image.nil?
			logger.debug "Fetching profile image url for #{name}"
			self.profile_image = Twitter.user(name).profile_image_url
			self.save
		end

		profile_image
	end

	protected

	def self.set_time_zone
		Time.zone = "Pacific Time (US & Canada)"
	end
end
