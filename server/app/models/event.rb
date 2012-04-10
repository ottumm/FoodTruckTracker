require 'haversine_distance'

class Event < ActiveRecord::Base
	has_many :notifications
	has_many :corrections
	has_many :tweets, :through => :notifications

	validates :location, :latitude, :longitude, :start_time, :end_time, :formatted_address, :presence => true

	attr_accessor :distance, :time_zone

	def self.find_nearby sensor, range, date, time_zone
		clause = range_clause sensor, range
		clause[:start_time] = same_day_clause date
		where(clause).each do |event|
			event.time_zone = time_zone
			event.distance = haversine_distance sensor, event
		end.sort {|a, b| a.distance <=> b.distance}
	end

	def self.all_with_corrections time_zone
		all.select {|e| !e.corrections.empty?}.each do |e|
			e.time_zone = time_zone
		end.sort {|a, b| a.start_time <=> b.start_time}
	end

	def self.merge_all!
		events = all.sort_by {|e| [e.title, e.location, e.start_time]}
		prev = events.first
		events.last(events.length - 1).each do |cur|
			if !prev
				prev = cur
			elsif prev.merge! cur
				logger.debug "Destroy #{cur.inspect}"
				cur.destroy
				prev = nil
			else
				prev = cur
			end
		end
	end

	def merge! event
		if event.title == title && event.location == location && event.start_time.beginning_of_day == start_time.beginning_of_day
			logger.debug "Merging #{title} - #{location} at #{start_time}"
			event.tweets.each do |t|
				if !tweets.include? t
					logger.debug "  Push from #{event.id} to #{id} - #{location}"
					tweets.push t
				end
			end
			return true
		end

		false
	end

	def time_zone
		if @time_zone.nil?
			tweets.first.truck.time_zone
		else
			@time_zone
		end
	end

	def time_zone= tz
		@time_zone = tz
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
		tweets.first.truck.profile_image
	end

	def title
		tweets.first.truck.name
	end

	protected

	def self.time_clause date, time_zone
	def self.same_day_clause date
		if date == "all"
			return {}
		end

		date.beginning_of_day..date.beginning_of_day + 1.day
	end

	def self.mi_to_coord_range center, mi
		center - (mi * 0.02)..center + (mi * 0.02)
	end

	def self.range_clause sensor, range
		{:latitude => mi_to_coord_range(sensor[:latitude], range), :longitude => mi_to_coord_range(sensor[:longitude], range)}
	end
end
