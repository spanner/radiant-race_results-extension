class RememberCalculations < ActiveRecord::Migration
  def self.up
    add_column :race_performances, :prizes, :text
  end

  def self.down
    remove_column :race_performances, :prizes
  end
end
