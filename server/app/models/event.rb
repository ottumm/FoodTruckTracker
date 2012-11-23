require 'haversine_distance'

class Event < ActiveRecord::Base
	has_many :notifications, :dependent => :destroy
	has_many :corrections, :dependent => :destroy
	has_many :tweets, :through => :notifications
	belongs_to :truck

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
		all.each do |e|
			if merge_event! e
				logger.debug "Destroy #{e.inspect}"
				e.destroy
			end
		end
	end

	def self.merge_or_save! event
		if !merge_event! event
			event.save
		end

		event
	end

	def merge! event
		event.tweets.each {|t| add_tweet! t}
	end

	def time_zone
		if @time_zone.nil?
			truck.time_zone
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
		truck.profile_image
	end

	def title
		truck.name
	end

	def add_tweet! tweet
		if !tweets.include? tweet
			tweets.push tweet
		end
	end

	def map_image_url
		params = { 
			:size => "48x48",
			:center => "#{latitude},#{longitude}",
			:zoom => 15,
			#:key => "AIzaSyCoNyyQ_MuIRqQhMoNl_VP2C32P0EQM4NI",
			:sensor => "false"
		}

		"http://maps.googleapis.com/maps/api/staticmap?#{params.to_query}"
	end

	def self.range_clause center, range
		{:latitude => mi_to_coord_range(center[:latitude], range), :longitude => mi_to_coord_range(center[:longitude], range)}
	end

	protected

	def self.dist_clause n
		n-0.001..n+0.001
	end

	def self.merge_event! event
		merged = false

		where(:truck_id => event.truck.id, :latitude => dist_clause(event.latitude), :longitude => dist_clause(event.longitude), :start_time => same_day_clause(event.start_time)).where(event.id.nil? ? "id is not ?" : "id != ?", event.id).limit(1).each do |e|
			merged = true
			e.merge! event
		end

		merged
	end

	def self.same_day_clause date
		if date == "all"
			return {}
		end

		date.beginning_of_day..date.beginning_of_day + 1.day
	end

	def self.mi_to_coord_range center, mi
		center - (mi * 0.02)..center + (mi * 0.02)
	end
end
