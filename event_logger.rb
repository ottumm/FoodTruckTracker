require 'rubygems'
require 'yaml'
require 'twitter'
require 'icalendar'

class EventLogger
	attr_accessor :tweets

	def initialize
		@tweets = []
	end

	def log_entry(name, text, created)
		formatted_created  = created.nil?  ? "n/a" : created.strftime('%m/%d')
		puts "#{name} (#{formatted_created}) : #{text}"
	end

	def log(name, entry)
		if entry.is_a? Twitter::Status
			@tweets.push(entry)
			log_entry(name, entry.text, entry.created_at)
		else
			log_entry("#{name} - ical", entry.summary, entry.created)
		end
	end

	def write_to_dir(dir)
		return if dir.nil?
		path = dir + "/" + Time.now.strftime("%y_%m_%d_%H%M%S") + ".yml"
		File.open(path, 'w') { |f| f.write(YAML::dump(@tweets)) }
	end
end
