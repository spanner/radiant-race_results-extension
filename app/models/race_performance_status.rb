class RacePerformanceStatus
  attr_accessor :id, :name, :aliases

  def initialize(options = {})
    options = options.symbolize_keys
    @id, @name = options[:id], options[:name]
    @aliases = (options[:aliases] || []).collect {|name| name.to_s.downcase.intern}
  end
  
  def symbol
    @name.to_s.downcase.intern
  end
  
  def has_alias?(value)
    @aliases.include?(value.to_s.downcase.intern)
  end
  
  def to_s
    @name
  end
  
  def to_i
    @id
  end
  
  def self.[](value="")
    value = "?" if value.blank? || value == 0
    @@statuses.find { |status| status.symbol == value.to_s.downcase.intern || status.has_alias?(value) }
  end
  
  def self.find(id=0)
    @@statuses.find { |status| status.id.to_s == id.to_s }
  end
  
  def self.find_all
    @@statuses.dup
  end
  
  def self.from_pos_or_time(pos="",time="")
    if self[pos]
      self[pos]
    elsif pos.looks_like_number?
      self["Finished"]
    else
      self.from_time(time)
    end
  end

  def self.from_time(time="")
    if time.seconds > 0   # String.seconds returns 0 for a string that doesn't parse. See DurationExtensions for method.
      self["Finished"] 
    elsif self[time]
      self[time]
    else
      self["?"]
    end
  end
  
  @@statuses = [
    RacePerformanceStatus.new(:id => 0,   :name => '?',   :aliases => ['unknown'] ),
    RacePerformanceStatus.new(:id => 10,  :name => 'Ret', :aliases => ['retired', 'r', 'ret']),
    RacePerformanceStatus.new(:id => 20,  :name => 'DNF', :aliases => ['did not finish', 'x', 'dnf']),
    RacePerformanceStatus.new(:id => 30,  :name => 'TO',  :aliases => ['timed out', 't', 'to']),
    RacePerformanceStatus.new(:id => 50,  :name => 'Dsq', :aliases => ['disqualified', 'disq', 'd', 'dsq']),
    RacePerformanceStatus.new(:id => 100, :name => 'Finished')
  ]
end
