class Event < ActiveRecord::Base

	def self.find_today
		set_time_zone
		where :start_time => (Time.now.beginning_of_day..Time.now.beginning_of_day + 1.day)
	end

	def google_maps_url
		"http://maps.google.com/maps?q=#{CGI::escape formatted_address}"
	end

	def formatted_start_time
		Event.set_time_zone
		start_time.strftime "%l:%M %P"
	end

	def formatted_created_at
		Event.set_time_zone
		created_at.strftime "%a %b %e %l:%M %P"
	end

	def tweet_url
		"http://twitter.com/#{name}/status/#{tweet_id}"
	end

	protected

	def self.set_time_zone
		Time.zone = "Pacific Time (US & Canada)"
	end
end
