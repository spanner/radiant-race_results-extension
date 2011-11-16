class Race < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  has_many :instances, :class_name => 'RaceInstance'

  has_many :records, :class_name => 'RaceRecord'
  accepts_nested_attributes_for :records, :allow_destroy => true

  has_many :checkpoints, :class_name => 'RaceCheckpoint'
  accepts_nested_attributes_for :checkpoints, :allow_destroy => true
  
  belongs_to :picture_asset, :class_name => 'Asset'
  accepts_nested_attributes_for :picture_asset, :allow_destroy => true

  belongs_to :map_asset, :class_name => 'Asset'
  accepts_nested_attributes_for :map_asset, :allow_destroy => true

  before_save :ensure_finish_checkpoint
  
  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_length_of :slug, :maximum => 100, :message => '%{count}-character limit'
  validates_format_of :slug, :with => %r{^([-_.A-Za-z0-9]*|)$}, :message => 'not URL-friendly'

  object_id_attr :filter, TextFilter

  default_scope :order => 'name ASC'
  named_scope :except, lambda { |race|
    { :conditions => ["NOT races.id = ?", race.id] }
  }

  def to_param
    slug
  end

  def latest
    instances.past.first   # they sort by start time desc
  end

  def in(name)
    instances.find_by_name(name)
  end
  
  def next
    instances.future.first
  end
  
  def record(category_name="M")
    category = RaceCategory.find_or_create_by_normalized_name(category_name)
    if new_record?
      self.records.build(:race_category => category)
    else 
      RaceRecord.find_or_create_by_race_id_and_race_category_id(self.id, category.id)
    end
  end
  
  def checkpoint_before(cp)
    checkpoints.at(checkpoints.index(cp) - 1) if checkpoints.include?(cp) and checkpoints.first != cp
  end

  def checkpoint_after(cp)
    checkpoints.at(checkpoints.index(cp) + 1) if checkpoints.include?(cp) and checkpoints.last != cp
  end
  
protected

  def ensure_finish_checkpoint
    self.checkpoints << RaceCheckpoint.new(:name => "Finish") unless checkpoints.find_by_name('Finish')
  end

end

