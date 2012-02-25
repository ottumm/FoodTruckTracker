require 'rubygems'
require 'bundler/setup'
require 'twitter'
require 'yaml'

path = ARGV[0]
tweets = {}

Dir.foreach(path).map {|v| "#{path}/#{v}"}.select {|v| File.file?(v)}.each do |file|
	YAML::load(File.open(file).read).each {|tweet| tweets[tweet.id] = tweet}
end

tweet_list = []
tweets.each {|k, v| tweet_list.push(v)}
tweet_list.sort {|a,b| a.id <=> b.id}.each {|t| puts "#{t.created_at}\t#{t.text}"}
