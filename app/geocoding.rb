require 'rubygems'
require 'bundler/setup'
require 'rest_client'
require 'json'

# TODO: add caching to avoid hitting the Google API rate limit

def geocode(text, opts={})
	def normalize(address)
		ret = address.gsub /\/|&/, " & "
		ret.gsub! /.*\s+(\S+\s+(and|&))/, "\\1"
		ret.gsub /\s\s/, " "
	end

	def geocode_address(a)
		address = normalize(a)
		puts "Google geocode( #{address} )"
		res = RestClient.get 'http://maps.googleapis.com/maps/api/geocode/json', :params => {:address => address, :sensor => "false"}
		JSON.parse(res.to_s)["results"]
	end

	address = opts[:near] ? "#{text} near #{opts[:near]}" : text

	res = geocode_address address
	if opts[:near] && (res.length == 0 || res[0]["formatted_address"] == opts[:near])
		res = geocode_address text
	end
	return res.empty? ? nil : res[0]
end
