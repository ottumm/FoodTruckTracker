require 'rubygems'
require 'bundler/setup'
require 'rspec'
require "./read_tweet_corpus"
require "../tweet_parser"

# TODO: return the actual location rather than the "tweet text" location

describe "#parse_events" do
	read_tweet_corpus.each do |test|
		it "parses \"#{test[:created_at]} - #{test[:text]}\"" do
			parsed = TweetParser.events test[:text], test[:created_at], "Pacific Time (US & Canada)", "San Francisco, CA"
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

describe "#parse_locations" do
	read_locations_corpus.each do |test|
		it "parses \"#{test[:text]}\"" do
			normalized = TweetParser.normalize test[:text]
			LocationParser.parse(normalized, :near => "San Francisco, CA")[:loc].should == test[:loc]
		end
	end
end
