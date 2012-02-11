#!/usr/bin/ruby

require 'rubygems'
require 'twitter'
require 'ruby-debug'

regex = $ARGV[0]
last_tweet_id = $ARGV[1]

Twitter.list_timeline("ottumm", "food-trucks", {:since_id => (last_tweet_id or 1)}).each do |tweet|
  if (tweet.text =~ /#{regex}/i)
    puts "@#{tweet.user.screen_name} (#{tweet.id}): #{tweet.text}"
  end
end
