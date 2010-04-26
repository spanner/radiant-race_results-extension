class RaceAttachments < ActiveRecord::Migration
  def self.up
    add_column :races, :picture_asset_id, :integer
    add_column :races, :map_asset_id, :integer
  end

  def self.down
    remove_column :races, :picture_asset_id
    remove_column :races, :map_asset_id
  end
end
