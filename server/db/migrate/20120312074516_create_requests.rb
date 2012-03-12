class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :client_id
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
