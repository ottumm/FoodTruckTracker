require 'json'

class Geocache < ActiveRecord::Base
	serialize :result
end
