class StoreIntervals < ActiveRecord::Migration
  def self.up
    add_column :race_checkpoint_times, :interval, :integer
  end

  def self.down
    remove_column :race_checkpoint_times, :interval
  end
end
