class CreateLocationTagMaps < ActiveRecord::Migration[4.2]
  def self.up
    create_table :location_tag_maps do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :location_tag_maps
  end
end
