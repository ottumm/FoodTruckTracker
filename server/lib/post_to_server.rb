require 'rubygems'
require 'bundler/setup'
require 'rest_client'

def post_event_to_server(server, event, tweet)
	url = "http://#{server}/events.json"
	puts "POST #{url} #{event}"
	RestClient.post(url,
		"truck[name]" => tweet.user.screen_name,
		"truck[time_zone]" => tweet.user.time_zone,
		"truck[profile_image]" => tweet.user.profile_image_url,
		"tweet[text]" => CGI.unescapeHTML(tweet.text),
		"tweet[timestamp]" => tweet.created_at,
		"tweet[tweet_id]" => tweet.id,
		"event[location]" => event[:loc],
		"event[formatted_address]" => event[:formatted_address],
		"event[latitude]" => event[:latitude],
		"event[longitude]" => event[:longitude],
		"event[start_time]" => event[:time],
		"event[end_time]" => event[:end],
		"commit" => "Create Event")
end
