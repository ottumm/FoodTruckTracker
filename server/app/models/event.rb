require 'haversine_distance'

class Event < ActiveRecord::Base
	has_many :notifications
	has_many :corrections
	has_many :tweets, :through => :notifications

	attr_accessor :distance, :time_zone

	def self.find_today date, time_zone
		where(time_clause(date, time_zone)).order(:start_time).each do |event|
			event.time_zone = time_zone
		end
	end

	def self.find_nearby sensor, range, date, time_zone
		find_today(date, time_zone).select do |event|
			event.distance = haversine_distance sensor, event
			event.distance < range
		end.sort {|a, b| a.distance <=> b.distance}
	end

	def self.all_with_corrections time_zone
		all.select {|e| !e.corrections.empty?}.each do |e|
			e.time_zone = time_zone
		end.sort {|a, b| a.start_time <=> b.start_time}
	end

	def self.merge! event
		event
	end

	def time_zone= tz
		@time_zone = tz
		tweets.each {|t| t.time_zone = tz}
		corrections.each {|c| c.time_zone = tz}
		self
	end
	
	def map_url
		"http://maps.google.com/maps?q=#{CGI::escape formatted_address}"
	end

	def start_time
		super.in_time_zone time_zone
	end

	def end_time
		super.in_time_zone time_zone
	end

	def formatted_start_time
		start_time.strftime "%l:%M %P"
	end

	def formatted_distance
		if distance then "%.1f mi" % distance else "n/a" end
	end

	def avatar_url
		tweets.first.profile_image
	end

	def title
		tweets.first.user
	end

	protected

	def self.time_clause date, time_zone
		if date == "all"
			return {}
		end

		{ :start_time => date.beginning_of_day..date.beginning_of_day + 1.day }
	end
end
