require 'default_time_zone'

class Truck < ActiveRecord::Base
	has_many :postings
	has_many :tweets, :through => :postings
	has_many :events

	def current_location
		event = most_recent_event
		event.nil? ? "(none)" : event.formatted_address
	end

	def most_recent_event
		events.sort {|a,b| b.start_time <=> a.start_time}.first
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
