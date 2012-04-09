require 'default_time_zone'

class Truck < ActiveRecord::Base
	has_many :postings
	has_many :tweets, :through => :postings

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
 
		super
	end
end
