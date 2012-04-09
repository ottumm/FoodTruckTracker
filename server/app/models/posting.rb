class Posting < ActiveRecord::Base
	belongs_to :truck
	belongs_to :tweet
end
