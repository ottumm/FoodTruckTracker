class AddTimeZoneToSources < ActiveRecord::Migration
  def change
    add_column :sources, :time_zone, :string
  end
end
