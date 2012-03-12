class AddTruckProfileImageToEvents < ActiveRecord::Migration
  def change
    add_column :events, :profile_image, :string

  end
end
