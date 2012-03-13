require 'rubygems'
require 'bundler/setup'
require 'json'
require 'optparse'
require "#{File.dirname(__FILE__)}/ical"
require "#{File.dirname(__FILE__)}/event_logger"
require "#{File.dirname(__FILE__)}/tweet_parser"
require "#{File.dirname(__FILE__)}/geo"
require "#{File.dirname(__FILE__)}/post_to_server"

def main(options, lists)
  logger = EventLogger.new
  filter = options[:cal_filter]
  filtered_cal = ICal.create :name => options[:cal_name]
  already_seen = Set.new
  
  lists.each do |list|
    ICal.merge_into!(filtered_cal, get_calendar(list, filter, logger, options[:server], already_seen))
  end

  ICal.to_file(filtered_cal, options[:output])
  logger.write_to_dir(options[:tweet_dir])
  if logger.tweets.length > 0
    File.open("log.txt", "a") {|f| f.puts "#{Time.now} : #{logger.tweets.length} new tweets"}
  end
end

def get_list_name(list)
  "#{list['user']}-#{list['name']}"
end

def get_calendar(list, filter, logger, server, already_seen)
  calendar = timeline_to_ical list, logger, server, already_seen
  ICal.filter calendar, filter, get_list_name(list)
end

def timeline_to_ical(list, logger, server, already_seen)
  cal = get_twitter_calendar list
  last_tweet_id = get_last_tweet_id list
  latest_tweet_id = 0

  fetch_tweets(list, last_tweet_id).each do |tweet|
    if already_seen.include? tweet.id
      next
    end

    already_seen.add tweet.id
    latest_tweet_id = tweet.id unless tweet.id < latest_tweet_id
    logger.log(tweet.user.screen_name, tweet)
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
    ICal.to_file cal, twitter_calendar_path(get_list_name list)
    File.open(last_tweet_id_path(get_list_name list), 'w') {|f| f.write latest_tweet_id}
  end

  return cal
end

def get_last_tweet_id(list)
  file = last_tweet_id_path(get_list_name list)
  if File.exists? file
    return File.open(file).read
  end

  return nil
end

def cals_dir
  return "cals"
end

def last_tweet_id_path(name)
  return "#{cals_dir}/#{name}.tweet"
end

def twitter_calendar_path(name)
  return "#{cals_dir}/#{name}.ics"
end

def get_twitter_calendar(name)
  cal_file = twitter_calendar_path name
  if File.exists? cal_file
    begin
      return Icalendar::parse(File.open(cal_file).read).first
    rescue Exception => e
      $stderr.puts "#{e.message} in #{cal_file}"
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

def fetch_tweets(list, since_id)
  puts "Fetching timeline for #{get_list_name list} since #{since_id}"
  return Twitter.list_timeline(list["user"], list["name"], {:since_id => (since_id or 1)})
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

main(options, c["lists"])
