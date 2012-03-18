require 'haversine_distance'

class Event < ActiveRecord::Base
	has_many :notifications
	has_many :tweets, :through => :notifications

	attr_accessor :distance, :time_zone

	def self.find_today date, time_zone
		where(time_clause(date, time_zone)).order(:start_time).map do |event|
			event.time_zone = time_zone
			event.tweets.map do |tweet|
				tweet.time_zone = time_zone
				tweet
			end
			event
		end
	end

	def self.find_nearby sensor, range, date, time_zone
		find_today(date, time_zone).select do |event|
			event.distance = haversine_distance(sensor, event)
			event.distance < range
		end.sort {|a, b| a.distance <=> b.distance}
	end

	def map_url
		"http://maps.google.com/maps?q=#{CGI::escape formatted_address}"
	end

	def formatted_start_time
		start_time.in_time_zone(time_zone).strftime "%l:%M %P"
	end

	def to_mi km
		km * 0.621371192
	end

	def formatted_distance
		if distance then "%.1f mi" % to_mi(distance) else "n/a" end
	end

	def avatar_url
		tweets.first.profile_image_url
	end

	def title
		tweets.first.user
	end

	protected

	def self.time_clause date, time_zone
		if date == "all"
			return {}
		end

		if date
			now = Date.parse(date).to_time
		else
			now = Time.now.in_time_zone time_zone
		end
		{ :start_time => now.beginning_of_day..now.beginning_of_day + 1.day }
	end
end
