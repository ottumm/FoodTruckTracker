class AddInitialSourceList < ActiveRecord::Migration
  def up
  	Source.new(:user => "ottumm", :name => "food-trucks", :location => "San Francisco, CA", :time_zone => "Pacific Time (US & Canada)").save
  	Source.new(:user => "twitsnationSFT", :name => "san-francisco", :location => "San Francisco, CA", :time_zone => "Pacific Time (US & Canada)").save
  	Source.new(:user => "sfcarts", :name => "san-francisco-food-carts", :location => "San Francisco, CA", :time_zone => "Pacific Time (US & Canada)").save
  	Source.new(:user => "sfcarts", :name => "new-york-food-carts", :location => "New York, NY", :time_zone => "Eastern Time (US & Canada)").save
  end

  def down
  end
end
