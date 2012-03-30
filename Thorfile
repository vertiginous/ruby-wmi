$:.push File.expand_path("../lib", __FILE__)
require 'ruby-wmi/version'

class Default < Thor
  class_option :verbose, 
    :type => :boolean, 
    :aliases => "-v", 
    :default => false

  desc "build", "Build the ruby-wmi gem"
  def build
    invoke :clean
    
    sh("gem build -V '#{source_root.join("ruby-wmi.gemspec")}'", source_root)
    FileUtils.mv(Dir.glob("*.gem"), "pkg/")
  rescue => e
    say e, :red
    exit 1
  end

  desc "clean", "Clean the project"
  def clean
    FileUtils.mkdir_p(pkg_path)
    Dir[pkg_path.join("*")].each { |f| FileUtils.rm(f, :force => true) }
  end

  desc "release", "Create a tag from the gem version, build, and push the ruby-wmi gem to rubygems"
  def release
    unless clean?
      say "There are files that need to be committed first.", :red
      exit 1
    end

    invoke :clean
    invoke :build

    tag_version {
      sh("gem push #{pkg_path.join("ruby-wmi-#{RubyWMI::VERSION}.gem")}")
    }
  end

  private

    def clean?
      sh_with_excode("git diff --exit-code")[1] == 0
    end

    def pkg_path
      source_root.join("pkg")
    end

    def sh(cmd, dir = source_root, &block)
      out, code = sh_with_excode(cmd, dir, &block)
      code == 0 ? out : raise(out.empty? ? "Running `#{cmd}` failed. Run this command directly for more detailed output." : out)
    end

    def sh_with_excode(cmd, dir = source_root, &block)
      cmd << " 2>&1"
      outbuf = ''

      Dir.chdir(dir) {
        outbuf = `#{cmd}`
        if $? == 0
          block.call(outbuf) if block
        end
      }

      [ outbuf, $? ]
    end

    def source_root
      Pathname.new File.dirname(File.expand_path(__FILE__))
    end
    
    def tag_version
      sh "git tag -a -m \"Version #{RubyWMI::VERSION}\" #{RubyWMI::VERSION}"
      say "Tagged: #{RubyWMI::VERSION}", :green
      yield if block_given?
      sh "git push --tags"
    rescue => e
      say "Untagging: #{RubyWMI::VERSION} due to error", :red
      sh_with_excode "git tag -d #{RubyWMI::VERSION}"
      say e, :red
      exit 1
    end
end
