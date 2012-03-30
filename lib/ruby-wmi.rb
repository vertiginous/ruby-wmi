require 'ruby-wmi/version'
require 'ruby-wmi/core_ext'

module RubyWMI
  autoload :privilege, 'ruby-wmi/privilege'
end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'ruby-wmi/base'
