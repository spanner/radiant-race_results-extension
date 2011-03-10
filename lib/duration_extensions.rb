module DurationExtensions

  # builds a duration object from a string like (but probably shorter than) dd:hh:mm:ss
  # (or any other non-numeral delimiter will work)

  def self.included(base)
    base.class_eval {
      extend ClassMethods
      include InstanceMethods
    }
  end

  module ClassMethods
    def parse(timecode)
      return timecode if timecode.is_a? Numeric
      tokens = timecode.split(/\D+/).map(&:to_i).reverse
      multipliers = [:seconds, :minutes, :hours, :days]
      parts = []
      seconds = tokens.inject(0) {|total, token|
        unit = multipliers.shift
        parts << [unit, token]
        total += token.send(unit)
      }
      new(seconds, parts)
    end
  end
  
  module InstanceMethods
    def timecode
      return '00:00:00' if value == 0
      h = (value/3600).floor;
      m = ((value % 3600)/60).floor;
      s = value % 60;
      sprintf("%d:%02d:%02d", h, m, s)
    end
    alias :to_timecode :timecode
  end
end

module StringExtensions
  def duration
    ActiveSupport::Duration.parse(self)
  end
  alias :seconds :duration
  
  def looks_like_duration?
    delimiters = Radiant::Config['race_results.delimiters'] || ':,.'
    true if self.match(/^[\d#{Regexp.escape(delimiters)}]+$/)
  end
  
  def looks_like_number?
    Float(s) != nil rescue false
  end
end

module NumericExtensions
  def to_timecode
    seconds.timecode
  end
  alias :timecode :to_timecode
end

ActiveSupport::Duration.send :include, DurationExtensions
String.send :include, StringExtensions
Numeric.send :include, NumericExtensions
