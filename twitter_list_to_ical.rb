#!/usr/bin/ruby

require 'rubygems'
require 'ruby-debug'
require 'twitter'
require 'chronic'

def main(last_tweet_id)
  Twitter.list_timeline("ottumm", "food-trucks", {:since_id => (last_tweet_id or 1)}).each do |user|
    date = parse_date(tweet)
    location = parse_location(tweet)
    puts "@#{tweet.user.screen_name} (#{tweet.created_at}): #{tweet.text}"
    puts "\tTime: #{date}"
    puts "\tLoc:  #{location}"
  end
end

def parse_date(tweet)
  get_phrases(tweet.text).each do |phrase|
    date = Chronic.parse(phrase, {:now => tweet.created_at})
    return date if date
  end
  
  return nil
end

def parse_location(tweet)
  match = /\s(@|at)\s?([\w&]*\s?[\w&]*)/.match(tweet.text)
  return match ? match[2] : nil
end

def get_phrases(text)
  phrases = Array.new
  words = text.split
  words.length.downto(1) do |len|
    0.upto(words.length - len) do |start|
      phrases.push(words.slice(start, len).join(" "))
    end
  end
  
  return phrases
end

main($ARGV[0])
