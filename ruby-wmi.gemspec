# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'ruby-wmi/version'

Gem::Specification.new do |s|
  s.name        = "ruby-wmi"
  s.version     = RubyWMI::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Gordon Thiesfeld", "Jamie Winsor"]
  s.email       = ["gthiesfeld@gmail.com", "jwinsor@riotgames.com"]
  s.homepage    = "https://github.com/vertiginous/ruby-wmi"
  s.summary     = %q{ruby-wmi is an ActiveRecord style interface for Microsoft's Windows Management Instrumentation provider.}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'thor'
end
