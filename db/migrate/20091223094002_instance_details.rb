class InstanceDetails < ActiveRecord::Migration
  def self.up
    add_column :race_instances, :notes, :text
    add_column :race_instances, :report, :text
  end

  def self.down
    remove_column :race_instances, :notes
    remove_column :race_instances, :report
  end
end
