class Filters < ActiveRecord::Migration
  def self.up
    add_column :races, :filter_id, :string
    add_column :race_instances, :filter_id, :string
  end

  def self.down
    remove_column :races, :filter_id
    remove_column :race_instances, :filter_id
  end
end
