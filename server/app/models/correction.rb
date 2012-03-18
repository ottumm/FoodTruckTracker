class Correction < ActiveRecord::Base
	belongs_to :event

	validates_associated :event
	validates_presence_of :event
	validates_presence_of :start_time
	validates_presence_of :end_time
	validates_presence_of :location
	validates_presence_of :latitude
	validates_presence_of :longitude
	validates_presence_of :formatted_address
end
