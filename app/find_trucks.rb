require 'rubygems'
require 'bundler/setup'
require 'json'
require 'optparse'
require "#{File.dirname(__FILE__)}/ical"
require "#{File.dirname(__FILE__)}/event_logger"
require "#{File.dirname(__FILE__)}/tweet_parser"
require "#{File.dirname(__FILE__)}/geo"
require "#{File.dirname(__FILE__)}/post_to_server"

def main(options, feeds)
  logger = EventLogger.new
  filter = options[:cal_filter]
  filtered_cal = ICal.create :name => options[:cal_name]
  
  feeds.each do |feed|
    ICal.merge_into!(filtered_cal, get_calendar(feed, filter, logger, options[:server]))
  end

  ICal.to_file(filtered_cal, options[:output])
  logger.write_to_dir(options[:tweet_dir])
  if logger.tweets.length > 0
    File.open("log.txt", "a") {|f| f.puts "#{Time.now} : #{logger.tweets.length} new tweets"}
  end
end

def get_calendar(feed, filter, logger, server)
  twitter  = feed["twitter"]
  ical     = feed["ical"]
  name     = "@#{twitter}"
  calendar = ical ? ICal.fixup(ICal.fetch(ical), name) : timeline_to_ical(twitter, logger, server)
  return ICal.filter(calendar, filter, name)
end

def timeline_to_ical(account, logger, server)
  cal = get_twitter_calendar account
  last_tweet_id = get_last_tweet_id account
  latest_tweet_id = 0

  fetch_tweets(account, last_tweet_id).each do |tweet|
    latest_tweet_id = tweet.id unless tweet.id < latest_tweet_id
    logger.log("@#{account}", tweet)
    TweetParser.events(tweet.text, tweet.created_at, tweet_timezone(tweet)).each do |event|
      event[:name]          = "@#{tweet.user.screen_name}"
      event[:end]           = event[:time] + 2.hours
      event[:description]   = tweet.text
      event[:creation_time] = tweet.created_at
      event[:tweet_id]      = tweet.id

      geocode = Geo.code event[:loc], :near => "Emeryville, CA, USA"
      if geocode
        event[:latitude]          = geocode["geometry"]["location"]["lat"]
        event[:longitude]         = geocode["geometry"]["location"]["lng"]
        event[:formatted_address] = geocode["formatted_address"]
        post_event_to_server server, event

        cal.event do
          dtstart     event[:time].to_datetime
          dtend       event[:end].to_datetime
          summary     event[:name]
          location    event[:loc]
          description "#{tweet.created_at} - #{event[:description]}\n#{tweet_url(tweet)}"
        end
      end
    end
  end

  if latest_tweet_id > 0
    Dir.mkdir cals_dir unless Dir.exists? cals_dir
    ICal.to_file cal, twitter_calendar_path(account)
    File.open(last_tweet_id_path(account), 'w') {|f| f.write latest_tweet_id}
  end

  return cal
end

def get_last_tweet_id(account)
  file = last_tweet_id_path account
  if File.exists? file
    return File.open(file).read
  end

  return nil
end

def cals_dir
  return "cals"
end

def last_tweet_id_path(account)
  return "#{cals_dir}/#{account}.tweet"
end

def twitter_calendar_path(account)
  return "#{cals_dir}/#{account}.ics"
end

def get_twitter_calendar(account)
  cal_file = twitter_calendar_path account
  if File.exists? cal_file
    begin
      return Icalendar::parse(File.open(cal_file).read).first
    rescue Exception => e
      $stderr.puts e.message
      $stderr.puts e.backtrace.map {|l| "\t#{l}"}
    end
  end

  return ICal.create
end    

def tweet_timezone(tweet)
  return (tweet.user.time_zone or "Pacific Time (US & Canada)")
end

def tweet_url(tweet)
  return "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
end

def fetch_tweets(account, since_id)
  puts "Fetching timeline for @#{account} since #{since_id}"
  return Twitter.user_timeline(account, {:since_id => (since_id or 1)})
end

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: find_trucks.rb [options...]"
  opts.on("-c", "--config [FILE]",   "Config file")         { |c| options[:config]     = c }
  opts.on("-o", "--cal [FILE]",      "Output to iCal file") { |o| options[:output]     = o }
  opts.on("-f", "--filter [REGEX]",  "Filter by REGEX")     { |f| options[:cal_filter] = f }
  opts.on("-n", "--name [NAME]",     "Calendar name")       { |n| options[:cal_name]   = n }
  opts.on("-d", "--tweet-dir [DIR]", "Log tweets here")     { |d| options[:tweet_dir]  = d }
  opts.on("-s", "--server [URL]",    "POST tweets here")    { |s| options[:server]     = s }
  opts.on("-h", "--help",            "Display this screen") { puts opts or exit }
end.parse!

options[:config]     = "find_trucks.config" unless options[:config]
c = JSON.parse(File.open(options[:config], "r").read)
options[:cal_name]   = c["cal"]["name"]     unless options[:cal_name]
options[:cal_filter] = c["cal"]["filter"]   unless options[:cal_filter]
options[:server]     = c["server"]          unless options[:server]

main(options, c["feeds"])
