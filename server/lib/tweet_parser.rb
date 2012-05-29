require "time_parser"
require "location_parser"

class TweetParser
  def self.events(text, created_at, time_zone, near)
    normalized_text = normalize text
    events = []
    split_events(normalized_text).each do |event_text|
      event = parse_time_and_location(event_text, created_at, time_zone, near)
      events.push(event) unless event.nil?
    end

    if events.empty?
      event = parse_time_and_location(normalized_text, created_at, time_zone, near)
      events.push(event) unless event.nil?
    end

    events
  end

  private

  def self.normalize(text)
    day_of_week  = '(?:sun(?:day)?|mon(?:day)?|tues?(:?day)?|wed(?:nesday)?|thur?s?(?:day)?|fri(?:day)?|sat(?:urday)?)'

    ret = text.clone
    ret.gsub! /(#{day_of_week})\./i, '\1:'
    ret.gsub! /https?:\/\/[^ ]*/, ''
    ret.gsub! /([a-z]):([^ ])/i, '\1: \2'
    return ret
  end

  def self.parse_time_and_location(text, created_at, time_zone, near)
    loc  = LocationParser.parse text, :near => near
    return nil if loc.nil?
    time = TimeParser.parse loc[:remaining], created_at, time_zone
    return nil if time.nil?

    Event.new :location          => loc[:loc],
              :latitude          => loc[:geo]["geometry"]["location"]["lat"],
              :longitude         => loc[:geo]["geometry"]["location"]["lng"],
              :formatted_address => loc[:geo]["formatted_address"],
              :start_time        => time,
              :end_time          => time + 2.hours
  end

  def self.split_events(text)
    return text.split(/[,;\.\!]/i)
  end
end
