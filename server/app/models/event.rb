require 'haversine_distance'

class Event < ActiveRecord::Base
	has_many :notifications
	has_many :tweets, :through => :notifications

	attr_accessor :distance, :time_zone

	def self.find_today time_zone, date
		where(:start_time => today(time_zone, date)).order(:start_time).map do |event|
			event.time_zone = time_zone
			event.tweets.map do |tweet|
				tweet.time_zone = time_zone
				tweet
			end
			event
		end
	end

	def self.find_nearby loc, range, time_zone
		find_today(time_zone, nil).select do |event|
			event.distance = haversine_distance(loc, event)
			event.distance < range
		end.sort {|a, b| a.distance <=> b.distance}
	end

	def map_url
		"http://maps.google.com/maps?q=#{CGI::escape formatted_address}"
	end

	def formatted_start_time
		start_time.in_time_zone(time_zone).strftime "%l:%M %P"
	end

	def formatted_distance
		if distance then "%.1f km" % distance else "n/a" end
	end

	def avatar_url
		tweets.first.profile_image_url
	end

	def title
		tweets.first.user
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
