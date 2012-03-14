require 'rubygems'
require 'bundler/setup'
require 'rest_client'

def post_event_to_server(server, event, tweet)
	url = "http://#{server}/events.json"
	puts "POST #{url} #{event}"
	RestClient.post(url,
		"tweet[text]" => tweet.text,
		"tweet[timestamp]" => tweet.created_at,
		"tweet[user]" => tweet.user.screen_name,
		"tweet[tweet_id]" => tweet.id,
		"event[location]" => event[:loc],
		"event[formatted_address]" => event[:formatted_address],
		"event[latitude]" => event[:latitude],
		"event[longitude]" => event[:longitude],
		"event[start_time]" => event[:time],
		"event[end_time]" => event[:end],
		"commit" => "Create Event")
end
