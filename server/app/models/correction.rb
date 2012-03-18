class Correction < ActiveRecord::Base
	belongs_to :event

	validates_associated :event
end
