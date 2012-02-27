require 'rubygems'
require 'bundler/setup'
require 'rspec'
require "#{File.dirname(__FILE__)}/read_tweet_corpus"
require "#{File.dirname(__FILE__)}/../app/tweet_parser"

describe "#parse_events" do
	read_tweet_corpus.each do |test|
		it "parses \"#{test[:created_at]} - #{test[:text]}\"" do
			parsed = TweetParser.events test[:text], test[:created_at], "Pacific Time (US & Canada)"
			test[:expected].map { |e| e.tap {|o| o.delete :geocode} }
			
			if parsed.length != test[:expected].length
				parsed.should =~ test[:expected]
			else
				parsed.length.times do |i|
					parsed[i].should == test[:expected][i]
				end
			end
		end
	end
end