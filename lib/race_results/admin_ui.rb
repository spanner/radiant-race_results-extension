module RaceResults
  module AdminUI

   def self.included(base)
     base.class_eval do

        attr_accessor :race
        alias_method :races, :race
        attr_accessor :race_instance
        alias_method :race_instances, :race_instance
        attr_accessor :race_club
        alias_method :race_clubs, :race_club
        attr_accessor :race_competitor
        alias_method :race_competitors, :race_competitor
      
        protected

          def load_default_race_regions
            returning OpenStruct.new do |race|
              race.edit = Radiant::AdminUI::RegionSet.new do |edit|
                edit.main.concat %w{edit_header edit_form}
                edit.form.concat %w{edit_name edit_metadata edit_distance edit_description edit_records edit_checkpoints}
              end
              race.new = race.edit
              race.index = Radiant::AdminUI::RegionSet.new do |index|
                index.thead.concat %w{title_header instances_header}
                index.tbody.concat %w{title_cell instances_cell}
                index.bottom.concat %w{buttons}
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

          def load_default_race_club_regions
            returning OpenStruct.new do |race_club|
              race_club.edit = Radiant::AdminUI::RegionSet.new do |edit|
                edit.main.concat %w{edit_header edit_form}
                edit.form.concat %w{edit_name edit_aliases}
              end
              race_club.new = race_club.edit
              race_club.index = Radiant::AdminUI::RegionSet.new do |index|
                index.thead.concat %w{title_header members_header aliases_header}
                index.tbody.concat %w{title_cell members_cell aliases_cell}
                index.bottom.concat %w{buttons}
              end
            end
          end

          def load_default_race_competitor_regions
            returning OpenStruct.new do |race_competitor|
              race_competitor.edit = Radiant::AdminUI::RegionSet.new do |edit|
                edit.main.concat %w{edit_header edit_form}
                edit.form.concat %w{edit_name edit_club edit_person}
              end
              race_competitor.new = race_competitor.edit
              race_competitor.index = Radiant::AdminUI::RegionSet.new do |index|
                index.thead.concat %w{title_header club_header races_header}
                index.tbody.concat %w{title_cell club_cell races_cell}
                index.bottom.concat %w{buttons}
              end
            end
          end
      
      end
    end
  end
end
