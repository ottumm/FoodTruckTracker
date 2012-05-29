class CreateGeocaches < ActiveRecord::Migration
  def change
    create_table :geocaches do |t|
      t.string :text
      t.text :result

      t.timestamps
    end
    add_index :geocaches, :text
  end
end
