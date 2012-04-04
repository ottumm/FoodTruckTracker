# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120404082736) do

  create_table "corrections", :force => true do |t|
    t.integer  "event_id",          :null => false
    t.datetime "start_time",        :null => false
    t.datetime "end_time",          :null => false
    t.float    "latitude",          :null => false
    t.float    "longitude",         :null => false
    t.string   "location",          :null => false
    t.string   "formatted_address", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "formatted_address"
    t.boolean  "verified"
    t.integer  "correction_id"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "tweet_id"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "requests", :force => true do |t|
    t.string   "client_id"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tweets", :force => true do |t|
    t.integer  "tweet_id",      :limit => 8
    t.string   "text"
    t.datetime "timestamp"
    t.string   "profile_image"
    t.string   "user"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "time_zone"
  end

end
