# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{radiant-race_results-extension}
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["spanner"]
  s.date = %q{2011-03-15}
  s.description = %q{Makes easy the uploading, analysis and display of race results. Built for fell races but should work for most timed or score events including those with checkpoints.}
  s.email = %q{will@spanner.org}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".gitignore",
     "README.md",
     "Rakefile",
     "VERSION",
     "app/controllers/admin/race_clubs_controller.rb",
     "app/controllers/admin/race_competitors_controller.rb",
     "app/controllers/admin/race_instances_controller.rb",
     "app/controllers/admin/races_controller.rb",
     "app/controllers/race_instances_controller.rb",
     "app/controllers/race_performances_controller.rb",
     "app/controllers/races_controller.rb",
     "app/helpers/races_helper.rb",
     "app/models/race.rb",
     "app/models/race_category.rb",
     "app/models/race_checkpoint.rb",
     "app/models/race_checkpoint_time.rb",
     "app/models/race_club.rb",
     "app/models/race_club_alias.rb",
     "app/models/race_competitor.rb",
     "app/models/race_instance.rb",
     "app/models/race_page.rb",
     "app/models/race_performance.rb",
     "app/models/race_performance_status.rb",
     "app/models/race_record.rb",
     "app/views/admin/race_checkpoints/_checkpoint.html.haml",
     "app/views/admin/race_club_aliases/_race_club_alias.html.haml",
     "app/views/admin/race_clubs/_club.html.haml",
     "app/views/admin/race_clubs/_form.html.haml",
     "app/views/admin/race_clubs/edit.html.haml",
     "app/views/admin/race_clubs/index.html.haml",
     "app/views/admin/race_clubs/new.html.haml",
     "app/views/admin/race_competitors/_competitor.html.haml",
     "app/views/admin/race_competitors/_form.html.haml",
     "app/views/admin/race_competitors/edit.html.haml",
     "app/views/admin/race_competitors/index.html.haml",
     "app/views/admin/race_instances/_form.html.haml",
     "app/views/admin/race_instances/edit.html.haml",
     "app/views/admin/race_instances/new.html.haml",
     "app/views/admin/race_records/_record.html.haml",
     "app/views/admin/races/_form.html.haml",
     "app/views/admin/races/_race.html.haml",
     "app/views/admin/races/edit.html.haml",
     "app/views/admin/races/index.html.haml",
     "app/views/admin/races/new.html.haml",
     "app/views/race_categories/show.html.haml",
     "app/views/race_clubs/show.html.haml",
     "app/views/race_instances/_summary.html.haml",
     "app/views/race_instances/index.html.haml",
     "app/views/race_instances/show.csv.erb",
     "app/views/race_instances/show.html.haml",
     "app/views/race_instances/splits.csv.erb",
     "app/views/race_instances/splits.html.haml",
     "app/views/race_performances/_performance.csv.erb",
     "app/views/race_performances/_performance.html.haml",
     "app/views/race_performances/_splits.csv.erb",
     "app/views/race_performances/_splits.html.haml",
     "app/views/race_performances/show.html.haml",
     "app/views/races/_standard_parts.html.haml",
     "app/views/races/index.html.haml",
     "app/views/races/show.html.haml",
     "artwork/csv.psd",
     "config/routes.rb",
     "cucumber.yml",
     "db/migrate/20091116130836_race_data.rb",
     "db/migrate/20091124095157_competitor_details.rb",
     "db/migrate/20091126110634_club_aliases.rb",
     "db/migrate/20091223094002_instance_details.rb",
     "db/migrate/20091224100524_race_distance.rb",
     "db/migrate/20091224100734_race_records.rb",
     "db/migrate/20091224105637_category_details.rb",
     "db/migrate/20091224115909_filters.rb",
     "db/migrate/20091228122837_record_holder.rb",
     "db/migrate/20100106104850_remember_calculations.rb",
     "db/migrate/20100426104801_race_attachments.rb",
     "db/migrate/20101005112007_race_category.rb",
     "db/migrate/20110315114349_store_intervals.rb",
     "features/support/env.rb",
     "features/support/paths.rb",
     "lib/duration_extensions.rb",
     "lib/race_results/admin_ui.rb",
     "lib/race_results/race_tags.rb",
     "lib/tasks/race_results_extension_tasks.rake",
     "public/images/admin/calendar_down.png",
     "public/images/admin/new-race.png",
     "public/images/race_results/csv.png",
     "public/javascripts/admin/races.js",
     "public/javascripts/tablesorter.js",
     "public/stylesheets/sass/admin/races.sass",
     "public/stylesheets/sass/race_results.sass",
     "race_results_extension.rb",
     "radiant-race_results-extension.gemspec",
     "spec/datasets/competitors_dataset.rb",
     "spec/datasets/race_sites_dataset.rb",
     "spec/datasets/races_dataset.rb",
     "spec/files/dunnerdale_2009.csv",
     "spec/files/long_duddon_2008.csv",
     "spec/lib/duration_spec.rb",
     "spec/models/race_category_spec.rb",
     "spec/models/race_club_spec.rb",
     "spec/models/race_instance_spec.rb",
     "spec/models/race_performance_spec.rb",
     "spec/models/race_performance_status_spec.rb",
     "spec/models/race_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "vendor/plugins/acts_as_list/README",
     "vendor/plugins/acts_as_list/init.rb",
     "vendor/plugins/acts_as_list/lib/active_record/acts/list.rb",
     "vendor/plugins/acts_as_list/test/list_test.rb"
  ]
  s.homepage = %q{http://github.com/radiant/radiant-race_results-extension}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Race results analysis and presentation for the Radiant CMS}
  s.test_files = [
    "spec/datasets/competitors_dataset.rb",
     "spec/datasets/race_sites_dataset.rb",
     "spec/datasets/races_dataset.rb",
     "spec/lib/duration_spec.rb",
     "spec/models/race_category_spec.rb",
     "spec/models/race_club_spec.rb",
     "spec/models/race_instance_spec.rb",
     "spec/models/race_performance_spec.rb",
     "spec/models/race_performance_status_spec.rb",
     "spec/models/race_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<radiant>, [">= 0.9.0"])
      s.add_runtime_dependency(%q<radiant-layouts-extension>, [">= 0"])
    else
      s.add_dependency(%q<radiant>, [">= 0.9.0"])
      s.add_dependency(%q<radiant-layouts-extension>, [">= 0"])
    end
  else
    s.add_dependency(%q<radiant>, [">= 0.9.0"])
    s.add_dependency(%q<radiant-layouts-extension>, [">= 0"])
  end
end

