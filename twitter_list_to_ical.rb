#!/usr/bin/ruby

require 'rubygems'
require 'active_support/core_ext/numeric/time'
require 'ruby-debug'
require 'twitter'
require 'chronic'
require 'icalendar'
require 'date'

def main(last_tweet_id, ical_file)
  cal = create_calendar()

  get_tweets(last_tweet_id).each do |tweet|
    time = parse_time(tweet)
    location = parse_location(tweet)
    puts "@#{tweet.user.screen_name} (#{tweet.created_at}): #{tweet.text}"
    puts "\tTime: #{time}"
    puts "\tLoc:  #{location}"

    if ( time && location )
      cal.event do
        dtstart     time.to_datetime
        dtend       (time + 2.hours).to_datetime
        summary     "@#{tweet.user.screen_name}"
        location    location
        description "#{tweet.created_at} - #{tweet.text}"
      end
    end
  end

  File.open(ical_file, 'w') {|f| f.write(cal.to_ical)} if ( ical_file )
end

def get_tweets(since_id)
  return Twitter.list_timeline("ottumm", "food-trucks", {:since_id => (since_id or 1)})
end

def create_calendar
  cal = Icalendar::Calendar.new
  cal.custom_property("X-WR-CALNAME;VALUE=TEXT", "Twitter Food Trucks")
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
    return time if time
  end
  
  return nil
end

def parse_location(tweet)
  match = /\s(@|at)\s?([\w&]*\s?[\w&]*)/.match(tweet.text)
  return match ? match[2] : nil
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

main($ARGV[1], $ARGV[0])
