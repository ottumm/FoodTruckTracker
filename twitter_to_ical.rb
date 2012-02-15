#!/usr/bin/ruby

require 'rubygems'
require 'active_support/core_ext/numeric/time'
require 'active_support/time'
require 'ruby-debug'
require 'twitter'
require 'chronic'
require 'icalendar'
require 'date'
require 'json'
require 'open-uri'
require 'optparse'
require 'tweet_logger'

def main(options, feeds)
  logger = TweetLogger.new
  filter = options[:filter]
  last_tweet = options[:last_tweet]
  filtered_cal = create_calendar({ :name => options[:cal_name] })
  
  feeds.each do |feed|
    twitter = feed["twitter"]
    ical    = feed["ical"]

    feed_cal = ical ? filter_ical(fetch_ical(ical), filter, "@#{twitter}") : timeline_to_ical(twitter, filter, last_tweet, logger)
    merge_calendar_into!(filtered_cal, feed_cal)
  end
  ical_to_file(filtered_cal, options[:output])
  save_tweets(logger, options[:tweet_dir])
end

def ical_to_file(cal, path)
  File.open(path, 'w') { |f| f.write(cal.to_ical) } unless path.nil?
end

def save_tweets(logger, dir)
  return if dir.nil?
  path = dir + "/" + Time.now.strftime("%y_%m_%d_%H%M%S") + ".yml"
  File.open(path, 'w') { |f| f.write(YAML::dump(logger.tweets)) }
end

def fetch_ical(url)
  puts "Fetching #{url}"
  return Icalendar::parse(open(url).read).first
end

def valid_created_field?(event)
  return event.created.to_time > Time.now - 10.years
end

def format_entry(name, text, location, time, created)
  formatted_created  = created.nil?  ? "n/a" : created.strftime('%m/%d')
  formatted_time     = time.nil?     ? "n/a" : time.strftime('%m/%d %H:%M')
  formatted_location = location.nil? ? "n/a" : location
  return "#{name} (#{formatted_created}) : #{formatted_time} @ #{location} : #{text}";
end

def filter_ical(cal, filter, name)
  filtered_cal = create_calendar()
  cal.events.each do |event|
    puts format_entry(name, "ical", event.summary, event.dtstart, event.created)
    if /#{filter}/i.match(event.summary)
      if !valid_created_field?(event)
        filtered_cal.event do
          dtstart  event.dtstart
          dtend    event.dtend
          summary  name
          location event.summary
        end
      else
        event.location = event.summary
        event.summary  = name
        filtered_cal.add_event(event)
      end
    end
  end

  return filtered_cal
end

def merge_calendar_into!(dest, src)
  src.events.each { |event| dest.add_event(event) }
  return dest
end

def timeline_to_ical(account, filter, last_tweet_id, logger)
  cal = create_calendar()

  fetch_tweets(account, last_tweet_id).each do |tweet|
    logger.log(tweet)
    time = parse_time(tweet)
    location = parse_location(tweet, filter)
    puts format_entry("@#{account}", tweet.text, location, time, tweet.created_at)
    if time && location
      cal.event do
        dtstart     time.to_datetime
        dtend       (time + 2.hours).to_datetime
        summary     "@#{tweet.user.screen_name}"
        location    location
        description "#{tweet.created_at} - #{tweet.text}"
      end
    end
  end

  return cal
end

def fetch_tweets(account, since_id)
  puts "Fetching timeline for @#{account}"
  return Twitter.user_timeline(account, {:since_id => (since_id or 1)})
end

def create_calendar(opts = {})
  cal = Icalendar::Calendar.new
  cal.custom_property("X-WR-CALNAME;VALUE=TEXT", opts[:name]) unless opts[:name].nil?
  cal.custom_property("X-WR-TIMEZONE;VALUE=TEXT", "America/Los_Angeles")

  cal.timezone do
    timezone_id          "America/Los_Angeles"
    
    daylight do
      timezone_offset_from "-0800"
      timezone_offset_to   "-0700"
      timezone_name        "PDT"
      dtstart              "19700308T020000"
      add_recurrence_rule  "FREQ=YEARLY;BYMONTH=3;BYDAY=2SU"
    end

    standard do
      timezone_offset_from "-0700"
      timezone_offset_to   "-0800"
      timezone_name        "PST"
      dtstart              "19701101T020000"
      add_recurrence_rule  "FREQ=YEARLY;BYMONTH=11;BYDAY=1SU"
    end
  end

  return cal
end

def parse_time(tweet)
  get_all_phrases(tweet.text).each do |phrase|
    time = Chronic.parse(phrase, {:now => tweet.created_at})
    return time unless time.nil?
  end
  
  return nil
end

def parse_location(tweet, filter)
  match = /\s(#{filter}[\w&]*\s?[\w&]*)/i.match(tweet.text)
  return match ? match[1] : nil
end

def get_all_phrases(text)
  phrases = []
  words = text.split
  words.length.downto(1) do |len|
    0.upto(words.length - len) do |start|
      phrases.push(words.slice(start, len).join(" "))
    end
  end
  
  return phrases
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

feeds = JSON.parse(File.open(options[:config], "r").read)
main(options, feeds)
