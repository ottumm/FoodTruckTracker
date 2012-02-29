class AddCreationTimeToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :creation_time, :datetime
  end
end
