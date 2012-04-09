class CreateTrucks < ActiveRecord::Migration
  def change
    create_table :trucks do |t|
      t.string :name
      t.string :profile_image
      t.string :time_zone

      t.timestamps
    end
    add_index :trucks, :name
  	
  	create_table :postings do |t|
      t.integer :truck_id
      t.integer :tweet_id

      t.timestamps
    end
    
    Event.all.each do |e|
    	truck = Truck.find_or_create_by_name e.tweets.first.user
    	truck.name = e.tweets.first.user
    	truck.profile_image = e.tweets.first.profile_image
    	truck.time_zone = e.tweets.first.time_zone
    	truck.save
    end

    Tweet.all.each do |t|
    	t.truck = Truck.find_by_name t.user
    	t.save
    end

    remove_column :tweets, :user
    remove_column :tweets, :profile_image
    remove_column :tweets, :time_zone
  end
end
