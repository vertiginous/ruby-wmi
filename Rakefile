# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/ruby-wmi.rb'

Hoe.new('ruby-wmi', RubyWMI::VERSION) do |p|
  p.rubyforge_name = 'ruby-wmi'
  p.author = 'Gordon Thiesfeld'
  p.email = 'gthiesfeld@gmail.com'
  p.summary = "ruby-wmi is an ActiveRecord style interface for Microsoft\'s Windows Management Instrumentation provider."
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.need_tar = false
  p.spec_extras = {:rdoc_options => ['--title' , 'ruby-wmi -- WMI, easier' ,
                       '--main' , 'README.txt' ,
                       '--line-numbers']}

end

# vim: syntax=Ruby
