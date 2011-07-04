# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-race_results-extension/version"

Gem::Specification.new do |s|
  s.name        = "radiant-race_results-extension"
  s.version     = RadiantRaceResultsExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantRaceResultsExtension::AUTHORS
  s.email       = RadiantRaceResultsExtension::EMAIL
  s.homepage    = RadiantRaceResultsExtension::URL
  s.summary     = RadiantRaceResultsExtension::SUMMARY
  s.description = RadiantRaceResultsExtension::DESCRIPTION

  s.add_dependency "radiant-layouts-extension"

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]

  s.post_install_message = %{
  Add this to your radiant project with:

    config.gem 'radiant-race_results-extension', :version => '~> #{RadiantRaceResultsExtension::VERSION}'

  }
end
