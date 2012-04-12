class MergeDuplicateEventsAgain < ActiveRecord::Migration
  def up
  	Event.merge_all!
  end

  def down
  end
end
