class RecordHolder < ActiveRecord::Migration
  def self.up
    add_column :race_records, :holder, :string
    add_column :race_records, :year, :string
  end

  def self.down
    remove_column :race_records, :holder
    remove_column :race_records, :year
  end
end
