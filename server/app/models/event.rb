class Event < ActiveRecord::Base

	def self.find_today
		set_time_zone
		where :start_time => (Time.now.beginning_of_day..Time.now.beginning_of_day + 1.day)
	end

	protected

	def self.set_time_zone
		Time.zone = "Pacific Time (US & Canada)"
	end
end
