class AddVerifiedToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :verified, :boolean
    add_column :events, :correction_id, :integer

  end
end
