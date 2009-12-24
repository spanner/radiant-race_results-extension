class RaceDistance < ActiveRecord::Migration
  def self.up
    add_column :races, :distance, :integer
    add_column :races, :climb, :integer
  end

  def self.down
    remove_column :races, :distance
    remove_column :races, :climb
  end
end
