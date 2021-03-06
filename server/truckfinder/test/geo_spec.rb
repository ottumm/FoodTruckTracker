require 'rubygems'
require 'bundler/setup'
require 'rspec'
require "./read_tweet_corpus"
require "../geo"

near = "Emeryville, CA, USA"

describe "#geocode" do
	read_tweet_corpus.each do |test|
		test[:expected].select {|e| !e[:geocode].nil?}.each do |event|
			it "\"#{event[:loc]}\"" do
				geo = Geo.code(event[:loc], :near => near)
				geo.should_not == nil

				if event[:geo]
					geo["formatted_address"].should == event[:geo]
				end
			end
		end
	end
end
