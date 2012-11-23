require 'default_time_zone'

class Truck < ActiveRecord::Base
	has_many :postings
	has_many :tweets, :through => :postings
	has_many :events

	attr_accessor :map_center, :map_range

	def current_location
		event = most_recent_event
		event.nil? ? "(none)" : event.formatted_address
	end

	def most_recent_event
		events.order("start_time DESC").limit(1).first
	end

	def all_locations opts = {}
		limit = opts[:range_limit] || Float::INFINITY
		north = south = east = west = nil

		locations = events.all(:select => "count(*) as count, events.*", :group => :formatted_address, :order => "count DESC").select do |coordinate|

			logger.debug "#{coordinate.location} lat: #{coordinate.latitude} lng: #{coordinate.longitude}"
			if north.nil? || (coordinate.longitude > north.longitude && haversine_distance(coordinate, north) < limit)
				north = coordinate
			end
			if south.nil? || (coordinate.longitude < south.longitude && haversine_distance(coordinate, south) < limit)
				south = coordinate
			end
			if east.nil? || (coordinate.latitude > east.latitude && haversine_distance(coordinate, east) < limit)
				east = coordinate
			end
			if west.nil? || (coordinate.latitude > west.latitude && haversine_distance(coordinate, west) < limit)
				west = coordinate
			end

			haversine_distance(coordinate, north) < limit && haversine_distance(coordinate, south) < limit && haversine_distance(coordinate, east) < limit && haversine_distance(coordinate, west) < limit
		end

		self.map_center = {:latitude => (east.latitude + west.latitude)/2, :longitude => (north.longitude + south.longitude)/2}
		self.map_range = [haversine_distance(east, west), haversine_distance(north, south)].max
		locations
	end

	def url
		"http://twitter.com/#{name}"
	end

	def profile_image
		if super.nil?
			logger.debug "Fetching profile image url for #{name}"
			update_attribute :profile_image, Twitter.user(name).profile_image_url
		end
 
		super
	end
 
	def time_zone
		if super.nil?
			logger.debug "Fetching time_zone for #{name}"
			tz = Twitter.user(name).time_zone
			update_attribute :time_zone, (tz or "none")
		end

		if super == "none"
			return default_time_zone
		end
 
		tz = super

		begin
			Time.now.in_time_zone tz
			return tz
		rescue
			return default_time_zone
		end
	end
end
