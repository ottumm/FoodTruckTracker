require 'bundler/setup'
require 'rubygems'
require 'chronic'
require 'active_support/core_ext/numeric/time'
require 'active_support/time'
require "#{File.dirname(__FILE__)}/get_all_phrases"

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

    composite_time
  end

  private

  def self.specific_day?(time, created_at)
    !time.nil? && (time.hour == 12 || time.day != created_at.day)
  end

  def self.specific_time?(time)
    !time.nil? && time.hour != 12 && time.hour != 0 && time.hour >= 11 && time.hour <= 21
  end

  def self.use_time?(time, other, created_at)
    other.nil? || (specific_time?(time) && specific_day?(time, created_at))
  end

  def self.combine_times(t1, t2, created_at)
    return t2 if use_time?(t2, t1, created_at)

    if specific_day?(t2, created_at)
      t1.clone.change({:day => t2.day})
    elsif specific_time?(t2)
      t1.clone.change({:hour => t2.hour, :min => t2.min})
    else
      t1.nil? ? nil : t1.clone
    end
  end

  def self.parse_with_chronic(*args)
    begin
      Chronic.parse(*args)
    rescue NoMethodError => e
      nil
    end
  end

  def self.parse_relative_time(phrase, created_at)
    time = parse_with_chronic(phrase, {:now => created_at, :ambiguous_time_range => 10})
    
    if time.nil? && /lunch/i.match(phrase)
      time = created_at.clone.change({:hour => 12})
    elsif time.nil? && /dinner/i.match(phrase)
      time = created_at.clone.change({:hour => 18})
    end

    time
  end
end
