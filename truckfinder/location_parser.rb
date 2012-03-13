class LocationParser
	def self.parse(text)
		remaining_text = text.clone
		loc = consume_location! remaining_text
		{:loc => loc, :remaining => remaining_text}
	end

	private

	def self.consume_location!(text)
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
	        loc.gsub! /#{loc_suffix}/i, ''
	        text.gsub! /#{Regexp.escape loc}/, ''
	        return loc
	      end
	    end

	    return nil
	end
end
