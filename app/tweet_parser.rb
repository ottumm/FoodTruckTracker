require 'rubygems'
require 'twitter'
require "#{File.dirname(__FILE__)}/geo"
require "#{File.dirname(__FILE__)}/time_parser"

class TweetParser
  def self.events(text, created_at, time_zone)
    normalized_text = normalize(text)
    events = []
    split_events(normalized_text).each do |event_text|
      event = parse_time_and_location(event_text, created_at, time_zone)
      events.push(event) unless event.nil?
    end

    if events.empty?
      event = parse_time_and_location(normalized_text, created_at, time_zone)
      events.push(event) unless event.nil?
    end

    return events
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

  def self.parse_time_and_location(text, created_at, time_zone)
    loc_text = text.clone
    loc  = consume_location!(loc_text)
    time = TimeParser.parse(loc_text, created_at, time_zone)
    return nil if time.nil? || loc.nil?
    return {:time => time, :loc => loc}
  end

  def self.split_events(text)
    return text.split(/[,;\.\!]/i)
  end

  def self.consume_location!(text)
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
end
