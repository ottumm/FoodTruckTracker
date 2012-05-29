require "#{File.dirname(__FILE__)}/geo"
require "#{File.dirname(__FILE__)}/get_all_phrases"

class LocationParser
	def self.parse text, opts
		loc = self.regex_parser text, opts
		loc[:remaining] = text.gsub /#{Regexp.escape loc[:loc]}/, '' unless loc.nil?
		loc
	end

	private

	def self.regex_parser text, opts
	    time         = '\d\d?(?:\d\d)?(?:am?|pm?)'
	    time_range   = "#{time}-#{time}"
	    loc_prefix   = '(?:@|at\\s|on\\s|[:\\.]\\s+)'
	    intersection = '[^\s,\.]+(?: and | ?& ?| ?\/ ?)[^\s,\.]+'
	    address      = '\d{1,4} [a-z]+ [a-z]+'
	    loc_suffix   = "(?: ?#{time_range}|[,\\.]| ?from).*"

	    [
	      /(#{address})/i,
	      /(#{intersection})/i,
	      /#{loc_prefix}(.*)/i
	    ].each do |pattern|
	      match = pattern.match(text)
	      if !match.nil? && !match[1].nil?
	        loc = match[1]
	        loc.gsub! /#{Regexp.escape loc_suffix}/, ''
	        geo = Geo.code loc, opts
	        if geo
	        	return { :loc => loc, :geo => geo }
	        end

	        Rails.logger.debug "Matched \"#{loc}\", which did not geocode"
	      end
	    end

	    nil
	end

	def self.phrase_parser text, opts
		Rails.logger.debug "Using phrase parser on \"#{text}\""

		get_all_phrases(text, :downto => 2).each do |phrase|
			geo = Geo.code phrase, opts
			if geo
				return { :loc => phrase, :geo => geo }
			end
		end

		nil
	end
end
