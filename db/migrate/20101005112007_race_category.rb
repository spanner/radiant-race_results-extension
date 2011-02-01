class RaceCategory < ActiveRecord::Migration
  def self.up
    add_column :races, :cat, :string
  end

  def self.down
    remove_column :races, :cat
  end
end
