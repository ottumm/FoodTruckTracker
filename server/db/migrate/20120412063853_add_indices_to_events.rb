class AddIndicesToEvents < ActiveRecord::Migration
  def change
  	add_index :events, :start_time
  	add_index :events, :latitude
  	add_index :events, :longitude
  end
end
