class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.integer :tweet_id, :limit => 8
      t.string :text
      t.datetime :timestamp
      t.string :profile_image
      t.string :user

      t.timestamps
    end

    create_table :notifications do |t|
      t.integer :tweet_id
      t.integer :event_id

      t.timestamps
    end

    Event.all.each do |e|
      e.tweets.push get_tweet e
    end

    remove_column :events, :name
    remove_column :events, :tweet_id
    remove_column :events, :creation_time
    remove_column :events, :profile_image
    remove_column :events, :description
  end

  def get_tweet event
    if Tweet.exists? event.tweet_id
      return Tweet.find_by_tweet_id event.tweet_id
    end

    tweet = Tweet.new do |t|
      t.tweet_id = event.tweet_id
      t.text = event.description
      t.timestamp = event.created_at
      t.profile_image = event.profile_image
      t.user = event.name[1..-1]
    end
    tweet.save
    tweet
  end
end
