class CreateCorrections < ActiveRecord::Migration
  def change
    create_table :corrections do |t|
      t.integer :event_id, :null => false
      t.datetime :start_time, :null => false
      t.datetime :end_time, :null => false
      t.float :latitude, :null => false
      t.float :longitude, :null => false
      t.string :location, :null => false
      t.string :formatted_address, :null => false

      t.timestamps
    end
  end
end
