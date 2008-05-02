# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/ruby-wmi.rb'

class Hoe
  attr_accessor :download_url
  attr_accessor :title
  attr_accessor :tagline

  alias_method :old_define_tasks, :define_tasks
  def define_tasks
    old_define_tasks

    desc "Generate webpage"
    task :generate_web => [:docs] do 
      mkdir_p 'web/public'
      require 'uv'
      require 'erubis'

      @samples = Dir['samples/*.rb'].map do |file|
        html = Uv.parse(  File.read(file), "xhtml", "ruby", false, "lazy")
        [file, html]
      end
      
      input = File.read('web/templates/index.html.erb')
      eruby = Erubis::Eruby.new(input)    # create Eruby object
      File.open('web/public/index.html', 'w+'){|f| f.puts eruby.result(binding()) }
    end
  end
end

Hoe.new('ruby-wmi', RubyWMI::VERSION) do |p|
  p.rubyforge_name = 'ruby-wmi'
  p.tagline = 'WMI queries, easier'
  p.title = "#{p.name} -- #{p.tagline}"
  p.author = 'Gordon Thiesfeld'
  p.email = 'gthiesfeld@gmail.com'
  p.summary = "ruby-wmi is an ActiveRecord style interface for Microsoft\'s Windows Management Instrumentation provider."
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.need_tar = false
  p.spec_extras = {
                  :rdoc_options => ['--title' , p.title ,
                       '--main' , 'README.txt' ,
                       '--line-numbers']
                  }
  p.download_url = 'http://rubyforge.org/projects/ruby-wmi/'

end

# pscp -r -load rubyforge web/public/images vertiginal@rubyforge.org:/var/www/gforge-projects/ruby-wmi/images
# needed tasks
#   * rdoc fixed.
#   * clobber_webpage
#   * publish_website

# vim: syntax=Ruby
