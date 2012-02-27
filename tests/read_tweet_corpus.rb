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
			if /^\t/.match line
				fields = line.split /\t/
				status[:expected].push({:time => Time.parse(fields[1]), :loc => fields[2], :geocode => fields[3]})
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
