class AssociateEventWithTruck < ActiveRecord::Migration
  def change
  	add_column :events, :truck_id, :integer

  	Event.all.each do |e|
  		e.truck = e.tweets.first.truck
  		e.save
  	end
  end
end
