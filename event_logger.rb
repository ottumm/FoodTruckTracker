require 'rubygems'
require 'yaml'
require 'twitter'
require 'ruby-debug'

class TweetLogger
	attr_accessor :tweets

	def initialize
		@tweets = []
	end

	def log(tweet)
		@tweets.push(tweet)
	end
end

