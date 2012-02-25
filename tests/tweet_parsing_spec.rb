require 'rubygems'
require 'bundler/setup'
require 'rspec'
require "#{File.dirname(__FILE__)}/../app/tweet_parsing"

def get_expected_parsings
	expected = []
	File.open("#{File.dirname(__FILE__)}/expected-parse.txt") do |file|
		status = {:text => nil, :created_at => nil, :expected => []}
		while line = file.gets
			line = line.chomp
			match = /^\t([^\t]+)\t(.*)/.match(line)
			if match
				status[:expected].push({:time => Time.parse(match[1]), :loc => match[2]})
			else
				expected.push(status.clone) unless status[:expected].empty?

				status[:expected] = []
				status[:created_at] = Time.parse(line.split("\t")[0])
				status[:text] = line.split("\t")[1]
			end
		end
		expected.push(status.clone) unless status[:expected].empty?
	end
	return expected
end

describe "#parse_events" do
	get_expected_parsings.each do |test|		
		it "parses \"#{test[:created_at]} - #{test[:text]}\" correctly" do
			parsed = parse_events(test[:text], test[:created_at])
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
