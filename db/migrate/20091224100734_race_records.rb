class RaceRecords < ActiveRecord::Migration
  def self.up
    create_table :race_records do |t|
      t.column :race_id,            :integer
      t.column :race_instance_id,   :integer
      t.column :race_competitor_id, :integer
      t.column :race_category_id,   :integer
      t.column :race_performance_id, :integer
      t.column :elapsed_time, :integer
      t.column :site_id, :integer
    end
    add_index :race_records, :site_id
    add_index :race_records, [:race_id, :race_category_id]
  end

  def self.down
    drop_table :race_records
  end
end
