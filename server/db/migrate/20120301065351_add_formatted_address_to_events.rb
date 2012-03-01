class AddFormattedAddressToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :formatted_address, :string
  end
end
