class Notification < ActiveRecord::Base
	belongs_to :event
	belongs_to :tweet
end
