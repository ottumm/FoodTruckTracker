require 'bundler/setup'
require 'rubygems'
require 'chronic'
require 'active_support/core_ext/numeric/time'
require 'active_support/time'

class TimeParser
  def self.parse(text, created_at, time_zone)
    Time.zone = ActiveSupport::TimeZone.new time_zone
    Chronic.time_class = Time.zone

    composite_time = nil
    get_all_phrases(text).each do |phrase|
      time = parse_relative_time(phrase, created_at.in_time_zone)
      if !time.nil?
        composite_time = combine_times(composite_time, time, created_at.in_time_zone)
      end
    end

    return composite_time
  end

  private

  def self.specific_day?(time, created_at)
    return !time.nil? && (time.hour == 12 || time.day != created_at.day)
  end

  def self.specific_time?(time)
    return !time.nil? && time.hour != 12 && time.hour != 0 && time.hour >= 11 && time.hour <= 21
  end

  def self.use_time?(time, other, created_at)
    return other.nil? || (specific_time?(time) && specific_day?(time, created_at))
  end

  def self.combine_times(t1, t2, created_at)
    return t2 if use_time?(t2, t1, created_at)

    if specific_day?(t2, created_at)
      return t1.clone.change({:day => t2.day})
    elsif specific_time?(t2)
      return t1.clone.change({:hour => t2.hour, :min => t2.min})
    else
      return t1.nil? ? nil : t1.clone
    end
  end

  def self.parse_with_chronic(*args)
    begin
      return Chronic.parse(*args)
    rescue NoMethodError => e
      arg_string = args.map {|a| a.inspect}.join(", ")
      $stderr.puts "Chronic.parse(#{arg_string})"
      $stderr.puts e.message
      $stderr.puts e.backtrace.map {|l| "\t#{l}"}
      return nil
    end
  end

  def self.parse_relative_time(phrase, created_at)
    time = parse_with_chronic(phrase, {:now => created_at, :ambiguous_time_range => 10})
    
    if time.nil? && /lunch/i.match(phrase)
      time = created_at.clone.change({:hour => 12})
    elsif time.nil? && /dinner/i.match(phrase)
      time = created_at.clone.change({:hour => 18})
    end

    return time
  end

  def self.get_all_phrases(text)
    phrases = []
    words = text.split(/\s+|\: |-(?:\d|:)*/)
    words.length.downto(1) do |len|
      0.upto(words.length - len) do |start|
        phrases.push(words.slice(start, len).join(" "))
      end
    end
    
    return phrases
  end
end
