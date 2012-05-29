class RemoveTypeColumnFromSources < ActiveRecord::Migration
  def change
  	remove_column :sources, :type
  end
end
