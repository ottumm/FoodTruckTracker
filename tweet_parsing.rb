require 'twitter'
require 'icalendar'
require 'chronic'

def timeline_to_ical(account, filter, last_tweet_id, logger)
  cal = create_calendar()

  fetch_tweets(account, last_tweet_id).each do |tweet|
    logger.log("@#{account}", tweet)
    time = parse_time(tweet)
    location = parse_location(tweet, filter)
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
