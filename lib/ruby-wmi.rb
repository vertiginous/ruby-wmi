require 'ruby-wmi/version'
require 'ruby-wmi/core_ext'

module RubyWMI
  autoload :privilege, 'ruby-wmi/privilege'
end

require 'ruby-wmi/base'

# Alias for {RubyWMI}
WMI = RubyWMI
