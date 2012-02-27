require 'rubygems'
require 'bundler/setup'
require 'json'
require 'optparse'
require "#{File.dirname(__FILE__)}/ical"
require "#{File.dirname(__FILE__)}/event_logger"
require "#{File.dirname(__FILE__)}/tweet_parsing"

def main(options, feeds)
  logger = EventLogger.new
  filter = options[:filter]
  last_tweet = options[:last_tweet]
  filtered_cal = create_calendar({ :name => options[:cal_name] })
  
  feeds.each do |feed|
    merge_calendar_into!(filtered_cal, get_calendar(feed, filter, last_tweet, logger))
  end

  ical_to_file(filtered_cal, options[:output])
  logger.write_to_dir(options[:tweet_dir])
end

def get_calendar(feed, filter, last_tweet, logger)
  twitter  = feed["twitter"]
  ical     = feed["ical"]
  name     = "@#{twitter}"
  calendar = ical ? fixup_ical(fetch_ical(ical), name) : timeline_to_ical(twitter, last_tweet, logger)
  return filter_ical(calendar, filter, name)
end

def timeline_to_ical(account, last_tweet_id, logger)
  cal = create_calendar()

  fetch_tweets(account, last_tweet_id).each do |tweet|
    logger.log("@#{account}", tweet) unless logger.nil?
    TweetParser.events(tweet.text, tweet.created_at).each do |event|
      puts "\t#{event[:time]}\t#{event[:loc]}"
      cal.event do
        dtstart     event[:time].to_datetime
        dtend       (event[:time] + 2.hours).to_datetime
        summary     "@#{tweet.user.screen_name}"
        location    event[:loc]
        description "#{tweet.created_at} - #{tweet.text}\n#{tweet_url(tweet)}"
      end
    end
  end

  return cal
end

def tweet_url(tweet)
  return "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
end

def fetch_tweets(account, since_id)
  puts "Fetching timeline for @#{account}"
  return Twitter.user_timeline(account, {:since_id => (since_id or 1)})
end

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: twitter_to_ical.rb [options...]"
  opts.on("-c", "--config FILE",        "Config file")         { |c| options[:config]     = c }
  opts.on("-o", "--output [FILE]",      "Output to iCal file") { |o| options[:output]     = o }
  opts.on("-f", "--filter [REGEX]",     "Filter by REGEX")     { |f| options[:filter]     = f }
  opts.on("-n", "--name [NAME]",        "Calendar name")       { |n| options[:cal_name]   = n }
  opts.on("-t", "--last-tweet-id [ID]", "Last Tweet id")       { |t| options[:last_tweet] = t }
  opts.on("-d", "--tweet-dir [DIR]",    "Log tweets here")     { |d| options[:tweet_dir]  = d }
  opts.on("-h", "--help",               "Display this screen") { puts opts or exit }
end.parse!

raise OptionParser::MissingArgument if options[:config].nil?

config = JSON.parse(File.open(options[:config], "r").read)
options[:cal_name] = config["name"]   if options[:cal_name].nil?
options[:filter]   = config["filter"] if options[:filter].nil?

main(options, config["feeds"])
