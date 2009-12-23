class RaceCategory < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  validates_presence_of :name

  named_scope :within, lambda {|category|
    category = RaceCategory.find_by_name(category) unless category.is_a? RaceCategory
    conditions = []
    bound = {}
    if category.age_above
      conditions.push "race_categories.age_above >= :above"
      bound[:above] = category.age_above
    end
    if category.age_below
      conditions.push "race_categories.age_below <= :below"
      bound[:below] = category.age_below
    end
    if category.gender
      conditions.push "race_categories.gender = :gender"
      bound[:gender] = category.gender
    end
    
    {
      :conditions => [conditions.join(' AND '), bound]   # note that the results will always include the passed category
    }
  }
  
  def self.find_or_create_by_normalized_name(name)
    name = normalized_name(name)
    unless category = find_by_name(name)
      category = new(:name => name)
      if matches = name.match(/^([A-Z]+)(\d*)$/)
        if matches[2] 
          category.send(matches[1].match(/U/) ? :age_below= : :age_above=, matches[2])
        end
        category.gender = matches[1].match(/L/) ? "F" : "M"
      end
      category.save!
    end
    category
  end
  
protected
  
  def self.normalized_name(name)
    name.gsub!(/\s/, '')
    name.upcase!
    case name
    when /M(\d\d)/
      "MV#{$1}"
    when /L(\d\d)/
      "LV#{$1}"
    when "F"
      "L"
    when /F(\d\d)/
      "LV#{$1}"
    when /FV(\d\d)/
      "LV#{$1}"
    when /FU(\d\d)/
      "LU#{$1}"
    when "W"
      "L"
    when /W(\d\d)/
      "LV#{$1}"
    when /WV(\d\d)/
      "LV#{$1}"
    when /WU(\d\d)/
      "LU#{$1}"
    else
      name
    end
  end

end

