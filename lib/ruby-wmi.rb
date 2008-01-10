class Ruby_wmi
  VERSION = '0.2.1'
end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'ruby-wmi/core_ext'
require 'ruby-wmi/base'
require 'ruby-wmi/cim'
require 'ruby-wmi/win32'