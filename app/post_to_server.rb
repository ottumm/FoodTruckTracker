require 'rubygems'
require 'bundler/setup'
require 'rest_client'

def post_event_to_server(server, event)
	url = "http://#{server}/events.json"
	puts "POST #{url} #{event}"
	RestClient.post(url,
		"event[name]" => event[:name],
		"event[location]" => event[:loc],
		"event[latitude]" => event[:latitude],
		"event[longitude]" => event[:longitude],
		"event[start_time]" => event[:time],
		"event[end_time]" => event[:end],
		"event[description]" => event[:description],
		"event[creation_time]" => event[:creation_time],
		"event[tweet_id]" => event[:tweet_id],
		"commit" => "Create Event")
end
