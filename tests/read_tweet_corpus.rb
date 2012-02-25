require 'rubygems'
require 'bundler/setup'
require 'active_support/core_ext/numeric/time'
require 'active_support/time'

def read_tweet_corpus
	corpus = []
	File.open("#{File.dirname(__FILE__)}/expected-parse.txt") do |file|
		status = {:text => nil, :created_at => nil, :expected => []}
		while line = file.gets
			line = line.chomp
			match = /^\t([^\t]+)\t(.*)/.match(line)
			if match
				status[:expected].push({:time => Time.parse(match[1]), :loc => match[2]})
			else
				corpus.push(status.clone) unless status[:expected].empty?

				status[:expected] = []
				status[:created_at] = Time.parse(line.split("\t")[0])
				status[:text] = line.split("\t")[1]
			end
		end
		corpus.push(status.clone) unless status[:expected].empty?
	end
	return corpus
end
