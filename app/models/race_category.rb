class RaceCategory < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  validates_presence_of :name
  
  # RaceCategory.within returns the list of categories (including this one) in which performances are eligible for prizes
  # in this category. Eg. for MV50 the list will include MV50, MV60 and MV70.
  
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
    
    { :conditions => [conditions.join(' AND '), bound] }
  }
  
  # RaceCategory.containing returns the list of categories in which a performance in this category is eligible for prizes
  # eg. for MV50, the list will include M, MV40 and MV50.
  # The list will always include both the passed category and any category of the right gender that has no other restrictions

  named_scope :containing, lambda {|category|
    category = RaceCategory.find_by_name(category) unless category.is_a? RaceCategory
    conditions = []
    bound = {}
    if category.gender
      conditions.push "(race_categories.gender = :gender)"
      bound[:gender] = category.gender
    end
    if category.age_above
      conditions.push "(race_categories.age_above IS NULL OR race_categories.age_above <= :above)"
      bound[:above] = category.age_above
    else
      conditions.push "(race_categories.age_above IS NULL)"
    end
    if category.age_below
      conditions.push "(race_categories.age_below IS NULL OR race_categories.age_below >= :below)"
      bound[:below] = category.age_below
    else
      conditions.push "(race_categories.age_below IS NULL)"
    end

    { :conditions => [conditions.join(' AND '), bound] }
  }
  
  default_scope :order => 'name ASC'

  def to_param
    name
  end

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
    name.gsub!(/\W*/, '')
    return "M" if name.blank?
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
    when "", nil
      "M"
    else
      name
    end
  end

end

