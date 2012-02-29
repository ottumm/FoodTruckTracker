class AddTweetIdToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :tweet_id, :integer, :limit => 8
  end
end
