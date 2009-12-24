module RaceResults
  module AdminUI

   def self.included(base)
     base.class_eval do

        attr_accessor :race
        alias_method :races, :race
        attr_accessor :race_instance
        alias_method :race_instances, :race_instance
      
        protected

          def load_default_race_regions
            returning OpenStruct.new do |race|
              race.edit = Radiant::AdminUI::RegionSet.new do |edit|
                edit.main.concat %w{edit_header edit_form}
                edit.form.concat %w{edit_title edit_metadata edit_distance edit_description}
              end
              race.new = race.edit
              race.index = Radiant::AdminUI::RegionSet.new do |index|
                index.thead.concat %w{title_header instances_header}
                index.tbody.concat %w{title_cell instances_cell}
                index.bottom.concat %w{new_button}
              end
            end
          end
      
          def load_default_race_instance_regions
            returning OpenStruct.new do |race_instance|
              race_instance.edit = Radiant::AdminUI::RegionSet.new do |edit|
                edit.main.concat %w{edit_header edit_form}
                edit.form.concat %w{edit_name edit_metadata edit_start edit_notes edit_file edit_report}
              end
              race_instance.new = race_instance.edit
            end
          end
      
      end
    end
  end
end
