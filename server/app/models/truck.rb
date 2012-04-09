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
			update_attribute :time_zone, Twitter.user(name).time_zone
		end
 
		super
	end
end
