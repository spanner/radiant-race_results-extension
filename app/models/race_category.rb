class RaceCategory < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  validates_presence_of :name

  named_scope :within, lambda {|category|
    conditions = []
    bound = []
    if category.age_above
      conditions.push "race_categories.age_above >= ?"
      bound.push category.age_above
    end
    if category.age_below
      conditions.push "race_categories.age_below <= ?"
      bound.push category.age_below
    end
    if category.gender
      conditions.push "race_categories.gender = ?"
      bound.push category.gender
    end
    {
      :conditions => [conditions.join(' AND '), *bound]   # note that the results will always include the passed category
    }
  }

end

