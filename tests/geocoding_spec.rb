require 'rubygems'
require 'bundler/setup'
require 'rspec'
require "#{File.dirname(__FILE__)}/read_tweet_corpus"
require "#{File.dirname(__FILE__)}/../app/geocoding"

near = "Emeryville, CA, USA"

describe "#geocode" do
	read_tweet_corpus.each do |test|
		test[:expected].select {|e| !e[:geocode].nil?}.each do |event|
			it "\"#{event[:loc]}\"" do
				geo = geocode(event[:loc], :near => near)
				geo.should_not == nil

				if event[:geo]
					geo["formatted_address"].should == event[:geo]
				end
			end
		end
	end
end
