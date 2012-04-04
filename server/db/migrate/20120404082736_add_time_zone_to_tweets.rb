class AddTimeZoneToTweets < ActiveRecord::Migration
  def change
  	add_column :tweets, :time_zone, :string
  end
end
