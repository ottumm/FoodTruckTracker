require 'rubygems'
require 'bundler/setup'
require 'rest_client'
require 'json'
require "#{File.dirname(__FILE__)}/../lib/haversine_distance"

class Geo
	@@cache = {}

	def self.code(text, opts)
		address = normalize(text)
		if address.empty?
			return nil
		end

		address = "#{address} near #{opts[:near]}"

		if @@cache[address]
			return @@cache[address]
		end

		reference = reference_location(opts[:near])
		geocode_address(address, opts[:near]).each do |location|
			if result_valid?(location, opts[:near]) && haversine_distance(coords(location), coords(reference)) < 160
				@@cache[address] = location
				return location
			end
		end

		nil
	end

	private

	def self.result_valid?(res, near)
		!res["formatted_address"].start_with?(near)# && !res["types"].include?("point_of_interest")
	end

	def self.reference_location(address)
		if @@cache[address]
			return @@cache[address]
		end

		@@cache[address] = geocode_address(address).first
	end

	def self.coords(l)
		{ :latitude => l["geometry"]["location"]["lat"], :longitude => l["geometry"]["location"]["lng"] }
	end

	def self.normalize(address)
		ret = address.gsub /\/|&|\+/, " and "
		ret.gsub /\s\s/, " "
		ret.gsub /\b\d\d?:\d\d\b/, ""
	end

	def self.format_bounds(coords)
		"#{coords[:sw_lat]},#{coords[:sw_long]}|#{coords[:ne_lat]},#{coords[:ne_long]}"
	end

	def self.geocode_address(address, opts={})
		puts "geocode: #{address}"
		r = RestClient.get 'http://maps.googleapis.com/maps/api/geocode/json', :params => {:address => address, :sensor => "false"}
		o = JSON.parse(r.to_s)
		if o["status"] != "OK"
			if o["status"] == "OVER_QUERY_LIMIT"
				raise "Google Maps API error: #{o['status']}"
			end

			return []
		end

		o["results"]
	end
end
