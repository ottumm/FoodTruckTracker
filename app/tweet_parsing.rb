require 'rubygems'
require 'twitter'
require 'chronic'
require "#{File.dirname(__FILE__)}/ical"
require "#{File.dirname(__FILE__)}/geocoding"

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

def parse_events(text, created_at)
  events = []
  split_events(text).each do |event_text|
    event = parse_time_and_location(event_text, created_at)
    events.push(event) unless event.nil?
  end

  if events.empty?
    event = parse_time_and_location(text, created_at)
    events.push(event) unless event.nil?
  end

  return events
end

def parse_time_and_location(text, created_at)
  loc_text = text.clone
  loc  = consume_location!(loc_text)
  time = parse_time(loc_text, created_at)
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

def specific_day?(time, created_at)
  return !time.nil? && (time.hour == 12 || time.day != created_at.day)
end

def specific_time?(time)
  return !time.nil? && time.hour != 12 && time.hour != 0 && time.hour >= 11 && time.hour <= 21
end

def use_time?(time, other, created_at)
  return other.nil? || (specific_time?(time) && specific_day?(time, created_at))
end

def combine_times(t1, t2, created_at)
  return t2 if use_time?(t2, t1, created_at)

  if specific_day?(t2, created_at)
    return t1.clone.change({:day => t2.day})
  elsif specific_time?(t2)
    return t1.clone.change({:hour => t2.hour, :min => t2.min})
  else
    return t1.nil? ? nil : t1.clone
  end
end

def parse_relative_time(*args)
  begin
    return Chronic.parse(*args)
  rescue NoMethodError => e
    arg_string = args.map {|a| a.inspect}.join(", ")
    $stderr.puts "Chronic.parse(#{arg_string})"
    $stderr.puts e.message
    $stderr.puts e.backtrace.map {|l| "\t#{l}"}
    return nil
  end
end

def parse_time(text, created_at)
  composite_time = nil
  get_all_phrases(text).each do |phrase|
    time = parse_relative_time(phrase, {:now => created_at, :ambiguous_time_range => 10})
    if !time.nil?
      composite_time = combine_times(composite_time, time, created_at)
    end
  end

  return composite_time
end

def add_missing_spaces(text)
  return text.gsub(/([a-z]):/i, '\1: ')
end

def consume_location!(text)
  loc_text = add_missing_spaces(text)
  [/(?:@|at\s|on\s)\s*([^,\.]+)/i,
   /([^\s,\.]+( and | ?& ?)[^\s,\.]+)/i,
   /\:\s+([^,\.]+)/i
  ].each do |pattern|
    match = pattern.match(loc_text)
    if !match.nil?
      loc = match[1]
      loc.gsub!(/ ?from.*/i, "")
      loc.gsub!(/ ?\d\d-\d\d?.*/, "")
      text.gsub!(Regexp.compile(Regexp.escape(loc)), "")
      return loc
    end
  end

  return nil
end

def get_all_phrases(text)
  phrases = []
  words = add_missing_spaces(text).split(/\s+|\: |-(?:\d|:)*/)
  words.length.downto(1) do |len|
    0.upto(words.length - len) do |start|
      phrases.push(words.slice(start, len).join(" "))
    end
  end
  
  return phrases
end
