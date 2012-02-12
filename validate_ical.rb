require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'ruby-debug'

url = ARGV[0]
doc = Nokogiri::HTML(open("http://severinghaus.org/projects/icv/?url=#{URI.escape(url)}"))
errors = doc.css(".parse-error td")
exit unless errors.length > 0

errors.each do |error|
	puts error.content
end

puts

doc.css(".context tr").each do |line|
	puts "#{line.children[0].content}\t#{line.children[2].content}"
end
