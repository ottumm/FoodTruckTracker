require 'haversine_distance'
require 'twitter'

class Event < ActiveRecord::Base
	attr_accessor :distance

	def self.find_today time_zone, date
		where(:start_time => today(time_zone, date)).order :start_time
	end

	def self.find_nearby loc, range, time_zone
		find_today(time_zone, nil).select do |event|
			event.distance = haversine_distance(loc, {:lat => event[:latitude], :long => event[:longitude]})
			event.distance < range
		end.sort {|a, b| a.distance <=> b.distance}
	end

	def google_maps_url
		"http://maps.google.com/maps?q=#{CGI::escape formatted_address}"
	end

	def formatted_start_time
		start_time.strftime "%l:%M %P"
	end

	def formatted_created_at
		created_at.strftime "%a %b %e %l:%M %P"
	end

	def formatted_distance
		if distance then "%.1f km" % distance else "n/a" end
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

	def self.today time_zone, date
		if date
			now = Date.parse(date).to_time
		else
			now = Time.now.in_time_zone time_zone
		end
		now.beginning_of_day..now.beginning_of_day + 1.day
	end
end
