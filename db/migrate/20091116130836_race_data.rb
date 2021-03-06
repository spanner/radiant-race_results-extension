class RaceData < ActiveRecord::Migration
  def self.up
    create_table :races do |t|
      t.column :name,               :string
      t.column :slug,               :string
      t.column :description,        :text
      t.column :created_by_id,      :integer
      t.column :updated_by_id,      :integer
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
      t.column :site_id,            :integer
    end
    add_index :races, [:name, :site_id], :unique => true
        
    create_table :race_instances do |t|
      t.column :race_id,            :integer
      t.column :name,               :string
      t.column :slug,               :string
      t.column :results_file_name,  :string
      t.column :results_content_type,  :string
      t.column :results_file_size,  :integer
      t.column :started_at,         :datetime
      t.column :created_by_id,      :integer
      t.column :updated_by_id,      :integer
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
      t.column :site_id,            :integer
    end
    add_index :race_instances, [:site_id]
    add_index :race_instances, [:slug, :race_id], :unique => true

    # this ought to be suitable for score courses too
    
    create_table :race_checkpoints do |t|
      t.column :race_id,            :integer
      t.column :position,           :integer
      t.column :name,               :string
      t.column :value,              :integer
      t.column :location,           :string
      t.column :description,        :text
      t.column :created_by_id,      :integer
      t.column :updated_by_id,      :integer
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
      t.column :site_id,            :integer
    end
    add_index :race_checkpoints, [:site_id]
    add_index :race_checkpoints, [:race_id]
    
    # clubs, categories and competitors are global

    create_table :race_categories do |t|
      t.column :name,               :string
      t.column :created_by_id,      :integer
      t.column :updated_by_id,      :integer
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
    end
    add_index :race_categories, :name, :unique => true
    
    create_table :race_clubs do |t|
      t.column :name,              :string
      t.column :url,                :string
      t.column :created_by_id,      :integer
      t.column :updated_by_id,      :integer
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
    end
    add_index :race_clubs, :name, :unique => true
    
    create_table :race_competitors do |t|
      t.column :name,               :string
      t.column :email,              :string
      t.column :reader_id,          :integer
      t.column :race_club_id,       :integer
      t.column :created_by_id,      :integer
      t.column :updated_by_id,      :integer
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
    end
    add_index :race_competitors, [:name, :race_club_id]
    
    create_table :race_performances do |t|
      t.column :number,             :integer
      t.column :position,           :integer
      t.column :race_instance_id,   :integer
      t.column :race_competitor_id, :integer
      t.column :race_category_id,   :integer
      t.column :race_club_id,       :integer
      t.column :dibber,             :string
      t.column :started_at,         :datetime
      t.column :elapsed_time,       :integer
      t.column :score,              :integer
      t.column :finished_at,        :datetime
      t.column :created_by_id,      :integer
      t.column :updated_by_id,      :integer
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
      t.column :status_id,          :integer
      t.column :site_id,            :integer
    end
    add_index :race_performances, [:site_id]
    add_index :race_performances, [:race_instance_id, :race_competitor_id, :race_category_id], :name => 'performances_by_competitor_and_category'
    
    create_table :race_checkpoint_times do |t|
      t.column :race_performance_id,:integer
      t.column :race_checkpoint_id, :integer
      t.column :elapsed_time,       :integer
      t.column :created_by_id,      :integer
      t.column :updated_by_id,      :integer
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
      t.column :site_id,            :integer
    end
    add_index :race_checkpoint_times, [:site_id]
  end

  def self.down
    drop_table :races
    drop_table :race_checkpoints
    drop_table :race_instances
    drop_table :race_categories
    drop_table :race_clubs
    drop_table :race_competitors
    drop_table :race_performances
    drop_table :race_checkpoint_times
  end
end
