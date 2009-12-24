class CategoryDetails < ActiveRecord::Migration
  def self.up
    add_column :race_categories, :gender, :string
    add_column :race_categories, :age_above, :integer
    add_column :race_categories, :age_below, :integer
  end

  def self.down
    remove_column :race_categories, :gender
    remove_column :race_categories, :age_above
    remove_column :race_categories, :age_below
  end
end
