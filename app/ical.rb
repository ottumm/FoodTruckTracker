require 'rubygems'
require 'bundler/setup'
require 'icalendar'
require 'active_support/core_ext/numeric/time'
require 'active_support/time'
require 'open-uri'

class ICal
  def self.fixup(cal, name)
    new_cal = ICal.create()
    cal.events.each do |event|
      if !valid_created_field?(event)
        new_cal.event do
          dtstart  event.dtstart
          dtend    event.dtend
          summary  name
          location event.summary
        end
      else
        event.location = event.summary
        event.summary = name
        new_cal.add_event(event)
      end
    end

    return new_cal
  end

  def self.filter(cal, filter, name)
    filtered_cal = ICal.create()
    cal.events.each do |event|
      if /#{filter}/i.match(event.location)
        filtered_cal.add_event(event)
      end
    end

    return filtered_cal
  end

  def self.to_file(cal, path)
    File.open(path, 'w') { |f| f.write(cal.to_ical) } unless path.nil?
  end

  def self.fetch(url)
    puts "Fetching #{url}"
    return Icalendar::parse(open(url).read).first
  end

  def self.merge_into!(dest, src)
    src.events.each { |event| dest.add_event(event) }
    return dest
  end

  def self.create(opts = {})
    cal = Icalendar::Calendar.new
    cal.custom_property("X-WR-CALNAME;VALUE=TEXT", opts[:name]) unless opts[:name].nil?
    cal.custom_property("X-WR-TIMEZONE;VALUE=TEXT", "America/Los_Angeles")

    cal.timezone do
      timezone_id          "America/Los_Angeles"
      
      daylight do
        timezone_offset_from "-0800"
        timezone_offset_to   "-0700"
        timezone_name        "PDT"
        dtstart              "19700308T020000"
        add_recurrence_rule  "FREQ=YEARLY;BYMONTH=3;BYDAY=2SU"
      end

      standard do
        timezone_offset_from "-0700"
        timezone_offset_to   "-0800"
        timezone_name        "PST"
        dtstart              "19701101T020000"
        add_recurrence_rule  "FREQ=YEARLY;BYMONTH=11;BYDAY=1SU"
      end
    end

    return cal
  end

  private

  def self.valid_created_field?(event)
    return event.created.nil? || event.created.to_time > Time.now - 10.years
  end
end
