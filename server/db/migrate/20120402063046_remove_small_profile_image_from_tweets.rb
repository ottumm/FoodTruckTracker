class RemoveSmallProfileImageFromTweets < ActiveRecord::Migration
  def change
  	remove_column :tweets, :small_profile_image
  end
end
