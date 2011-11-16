class MappingRoutes < ActiveRecord::Migration
  def self.up
    create_table :routes do |t|
      t.column :race_id, :integer
      t.column :closed, :boolean
    end
    create_table :points do |t|
      t.column :name, :string
      t.column :route_id, :integer
      t.column :pos, :integer
      t.column :required, :boolean
      t.column :lat, :decimal, :precision => 15, :scale => 10
      t.column :lng, :decimal, :precision => 15, :scale => 10
      t.column :gridref, :string
    end
  end

  def self.down
    drop_table :routes
    drop_table :points
  end
end
