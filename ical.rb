require 'rubygems'
require 'icalendar'
require 'active_support/core_ext/numeric/time'
require 'active_support/time'
require 'event_logger'
require 'open-uri'

def valid_created_field?(event)
  return event.created.to_time > Time.now - 10.years
end

def filter_ical(cal, filter, name, logger)
  filtered_cal = create_calendar()
  cal.events.each do |event|
    logger.log(name, event)
    if /#{filter}/i.match(event.summary)
      if !valid_created_field?(event)
        filtered_cal.event do
          dtstart  event.dtstart
          dtend    event.dtend
          summary  name
          location event.summary
        end
      else
        event.location = event.summary
        event.summary  = name
        filtered_cal.add_event(event)
      end
    end
  end

  return filtered_cal
end

def ical_to_file(cal, path)
  File.open(path, 'w') { |f| f.write(cal.to_ical) } unless path.nil?
end

def fetch_ical(url)
  puts "Fetching #{url}"
  return Icalendar::parse(open(url).read).first
end

def merge_calendar_into!(dest, src)
  src.events.each { |event| dest.add_event(event) }
  return dest
end

def create_calendar(opts = {})
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
