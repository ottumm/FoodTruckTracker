require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'rest_client'

file = ARGV[0]
res  = RestClient.post("http://severinghaus.org/projects/icv/",
	:ics => File.new(file),
	:MAX_FILE_SIZE => "1000000")

doc = Nokogiri::HTML(res.body)
errors = doc.css(".parse-error td")
exit unless errors.length > 0

errors.each {|e| $stderr.puts e.content}
puts

doc.css(".context tr").each {|l| $stderr.puts "#{line.children[0].content}\t#{line.children[2].content}"}
abort
