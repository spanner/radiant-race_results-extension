class CompetitorDetails < ActiveRecord::Migration
  def self.up
    add_column :race_competitors, :dob, :datetime
    add_column :race_competitors, :gender, :string
  end

  def self.down
  end
end
