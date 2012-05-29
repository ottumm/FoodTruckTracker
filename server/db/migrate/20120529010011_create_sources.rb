class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :user
      t.string :name
      t.string :type
      t.string :location
      t.integer :last_seen_id, :limit => 8

      t.timestamps
    end
  end
end
