class RaceInstanceCategory < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  belongs_to :race_instance
  belongs_to :race_category

  has_many :performances, :class_name => 'RacePerformance'
end

