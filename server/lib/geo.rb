require 'rest_client'
require 'json'
require 'haversine_distance'

class Geo
	def self.code(text, opts)
		address = normalize(text)
		if address.empty?
			return nil
		end

		address = "#{address} near #{opts[:near]}"

		unless (cached = Geocache.find_by_text address).nil?
			Rails.logger.debug "geocode cache hit \"#{address}\""
			return cached.result
		end

		reference = reference_location(opts[:near])
		geocode_address(address, opts[:near]).each do |location|
			if result_valid?(location, opts[:near]) && haversine_distance(coords(location), coords(reference)) < 160
				Geocache.new(:text => address, :result => location).save
				return location
			end
		end

		Geocache.new(:text => address, :result => nil).save
		nil
	end

	private

	def self.result_valid?(res, near)
		valid = !res["formatted_address"].start_with?(near)# && !res["types"].include?("point_of_interest")
		if !valid
			Rails.logger.debug "Invalid result: #{res['formatted_address']}"
		end
		valid
	end

	def self.reference_location(address)
		unless (cached = Geocache.find_by_text address).nil?
			Rails.logger.debug "geocode cache hit \"#{address}\" : #{cached.result}"
			return cached.result
		end

		location = geocode_address(address).first
		Geocache.new(:text => address, :result => location).save
		location
	end

	def self.coords(l)
		Rails.logger.debug "coords: #{l}"
		{ :latitude => l["geometry"]["location"]["lat"], :longitude => l["geometry"]["location"]["lng"] }
	end

	def self.normalize(address)
		ret = address.gsub /\/|&|\+/, " and "
		ret.gsub /\s\s/, " "
		ret.gsub /\b\d\d?:\d\d\b/, ""
	end

	def self.geocode_address(address, opts={})
		Rails.logger.debug "geocode: #{address}"
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
