require "tweet_parser"

task :find_trucks => :environment do
  already_seen = Set.new
  Source.all.each {|s| add_events_from_source s, already_seen}
end

def add_events_from_source source, already_seen
  latest_tweet_id = 0

  fetch_tweets(source).each do |tweet|
    if already_seen.include? tweet.id
      next
    end

    Rails.logger.debug "#{tweet.user.screen_name} - #{tweet.text}"

    already_seen.add tweet.id
    latest_tweet_id  = tweet.id unless tweet.id < latest_tweet_id
    time_zone        = tweet_timezone tweet, source
    default_location = tweet_location tweet, source

    TweetParser.events(CGI.unescapeHTML(tweet.text), tweet.created_at, time_zone, default_location).each do |event|
      truck = add_truck Truck.new(:name => tweet.user.screen_name, :time_zone => time_zone)
      tweet = add_tweet tweet_to_active_record(tweet), truck
      add_event truck, tweet, event
    end

    source.last_seen_id = latest_tweet_id
    source.save
  end
end

def tweet_to_active_record tweet
  Tweet.new :tweet_id => tweet.id, :text => tweet.text, :timestamp => tweet.created_at
end

def add_truck t
  existing = Truck.find_by_name t.name
  if !existing
    Rails.logger.debug "\tAdding truck: #{t.name}"
    t.save
    t
  else
    existing
  end
end

def add_tweet tweet, truck
  existing = Tweet.find_by_tweet_id tweet.tweet_id
  if !existing
    Rails.logger.debug "\tAdding tweet by #{truck.name}: #{tweet.tweet_id}"
    tweet.truck = truck
    tweet.save
    tweet
  else
    existing
  end
end

def add_event truck, tweet, event
  event.truck = truck
  existing = Event.find_by_truck_id_and_location_and_start_time truck.id, event.location, event.start_time
  if !existing
    Rails.logger.debug "\tAdding event: #{event.inspect}"
    event.add_tweet! tweet
    event.save
    event
  else
    Rails.logger.debug "\tAdding tweet to existing event: #{tweet.id}"
    existing.add_tweet! tweet
    existing.save
    existing
  end
end

def tweet_timezone tweet, source
  (tweet.user.time_zone or source.time_zone)
end

def tweet_location tweet, source
  tweet.place ? tweet.place.full_name : source.location
end

def fetch_tweets source
  Rails.logger.debug "Fetching timeline for #{source.user}/#{source.name} since #{source.last_seen_id}"
  Twitter.list_timeline source.user, source.name, {:since_id => (source.last_seen_id or 1)}
end
