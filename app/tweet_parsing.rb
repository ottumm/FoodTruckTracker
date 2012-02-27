require 'rubygems'
require 'twitter'
require "#{File.dirname(__FILE__)}/ical"
require "#{File.dirname(__FILE__)}/geocoding"
require "#{File.dirname(__FILE__)}/time_parsing"

def timeline_to_ical(account, last_tweet_id, logger)
  cal = create_calendar()

  fetch_tweets(account, last_tweet_id).each do |tweet|
    logger.log("@#{account}", tweet) unless logger.nil?
    parse_events(tweet.text, tweet.created_at).each do |event|
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

def normalize(text)
  day_of_week  = '(?:sun(?:day)?|mon(?:day)?|tues?(:?day)?|wed(?:nesday)?|thur?s?(?:day)?|fri(?:day)?|sat(?:urday)?)'

  ret = text.clone
  ret.gsub! /(#{day_of_week})\./i, '\1:'
  ret.gsub! /([a-z]):([^ ])/i, '\1: \2'
  return ret
end

def parse_events(text, created_at)
  normalized_text = normalize(text)
  events = []
  split_events(normalized_text).each do |event_text|
    event = parse_time_and_location(event_text, created_at)
    events.push(event) unless event.nil?
  end

  if events.empty?
    event = parse_time_and_location(normalized_text, created_at)
    events.push(event) unless event.nil?
  end

  return events
end

def parse_time_and_location(text, created_at)
  loc_text = text.clone
  loc  = consume_location!(loc_text)
  time = TimeParser.parse(loc_text, created_at)
  return nil if time.nil? || loc.nil?
  return {:time => time, :loc => loc}
end

def split_events(text)
  return text.split(/[,;\.\!]/i)
end

def fetch_tweets(account, since_id)
  puts "Fetching timeline for @#{account}"
  return Twitter.user_timeline(account, {:since_id => (since_id or 1)})
end

def consume_location!(text)
  time         = '\d\d?(?:\d\d)?(?:am?|pm?)'
  time_range   = "#{time}-#{time}"
  loc_prefix   = "(?:@|at\\s|on\\s|[:\\.]\\s+)"
  intersection = '[^\s,\.]+(?: and | ?& ?| ?\/ ?)[^\s,\.]+'
  loc_suffix   = "(?: ?#{time_range}|[,\\.]| ?from).*"

  [
    /(#{intersection})/i,
    /#{loc_prefix}(.*)/i
  ].each do |pattern|
    match = pattern.match(text)
    if !match.nil? && !match[1].nil?
      loc = match[1]
      loc.gsub! /#{loc_suffix}/i, ""
      text.gsub!(Regexp.compile(Regexp.escape(loc)), "")
      return loc
    end
  end

  return nil
end
