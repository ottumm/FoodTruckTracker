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

def main(truck_file, ical_file, last_tweet_id, filter)
  filtered_cal = create_calendar()
  trucks = JSON.parse(File.open(truck_file, "r").read)
  trucks.each do |truck|
    twitter = truck["twitter"]
    ical    = truck["ical"]

    truck_cal = ical ? filter_ical(fetch_ical(ical), filter, "@#{twitter}") : timeline_to_ical(twitter, filter, last_tweet_id)
    filtered_cal = merge_calendars(filtered_cal, truck_cal)
  end

  File.open(ical_file, 'w') {|f| f.write(filtered_cal.to_ical)} if ( ical_file )
end

def fetch_ical(url)
  puts "Fetching #{url}"
  return Icalendar::parse(open(url).read).first
end

def filter_ical(cal, filter, name)
  filtered_cal = create_calendar()
  cal.events.each do |event|
    puts "#{name} (ical)"
    puts "\tTime: #{event.dtstart}"
    puts "\tLoc : #{event.summary}"
    if ( /#{filter}/i.match(event.summary) )
      if event.created.to_time < Time.now - 10.years
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

def merge_calendars(cal1, cal2)
  merged_calendar = create_calendar()
  cal1.events.each { |event| merged_calendar.add_event(event) }
  cal2.events.each { |event| merged_calendar.add_event(event) }
  return merged_calendar
end

def timeline_to_ical(account, filter, last_tweet_id)
  cal = create_calendar()

  get_tweets(account, last_tweet_id).each do |tweet|
    time = parse_time(tweet)
    location = parse_location(tweet, filter)
    puts "@#{tweet.user.screen_name} (#{tweet.created_at}): #{tweet.text}"
    puts "\tTime: #{time}"     if time
    puts "\tLoc : #{location}" if location

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

  return cal
end

def fetch_tweets(account, since_id)
  puts "Fetching timeline for @#{account}"
  return Twitter.user_timeline(account, {:since_id => (since_id or 1)})
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

main(ARGV[0], ARGV[1], ARGV[2], "hollis")
