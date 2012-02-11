require 'rubygems'
require 'twitter'

Twitter.user_timeline(ARGV[1]).each do |tweet|
  print "#{tweet.text}\n" if (tweet.text =~ /#{ARGV[0]}/i)
end
