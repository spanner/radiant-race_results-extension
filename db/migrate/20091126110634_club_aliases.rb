class ClubAliases < ActiveRecord::Migration
  def self.up
    create_table :race_club_aliases do |t|
      t.column :race_club_id,       :integer
      t.column :name,               :string
      t.column :created_by_id,      :integer
      t.column :updated_by_id,      :integer
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
    end
    add_index :race_club_aliases, :race_club_id
  end

  def self.down
    drop_table :race_club_aliases
  end
end
