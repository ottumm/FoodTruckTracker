class AddSmallProfileImageToTweet < ActiveRecord::Migration
  def change
  	add_column :tweets, :small_profile_image, :string
  end
end
