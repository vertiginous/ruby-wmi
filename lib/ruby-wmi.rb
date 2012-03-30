require 'ruby-wmi/version'
require 'ruby-wmi/core_ext'
require 'win32ole'

WIN32OLE.codepage = WIN32OLE::CP_UTF8

module RubyWMI
  autoload :privilege, 'ruby-wmi/privilege'
  autoload :base, 'ruby-wmi/base'

  # Generic WMI exception class.
  class WMIError < StandardError
  end

  # Invalid Class exception class.
  class InvalidClass < WMIError
  end

  # Invalid Query exception class.
  class InvalidQuery < WMIError
  end

  # Invalid NameSpace exception class.
  class InvalidNameSpace < WMIError
  end
  
  # Read only exception class.
  class ReadOnlyError < WMIError
  end

  # Returns an array containing all the WMI subclasses
  # on a sytem.  Defaults to localhost
  #
  #   WMI.subclasses
  #   => ["Win32_PrivilegesStatus", "Win32_TSNetworkAdapterSettingError", ...]
  #
  #  For a more human readable version of subclasses when using options:
  #
  #   WMI.subclasses_of(:host => 'some_computer')
  #   => ["Win32_PrivilegesStatus", "Win32_TSNetworkAdapterSettingError", ...]
  #
  #   WMI.subclasses_of(
  #      :host => :some_computer,
  #      :namespace => "root\\Microsoft\\SqlServer\\ComputerManagement"
  #    )
  def subclasses(options ={})
    options.merge!(:method => :SubclassesOf)
    instances_of(options).
    map{ |subclass| subclass.Path_.Class }
  end
  alias :subclasses_of :subclasses

  # Returns an array containing all the WMI providers
  # on a sytem.  Defaults to localhost
  #
  #   WMI.providers
  #
  #  For a more human readable version of providers when using options:
  #
  #   WMI.providers_of(:host => :some_computer)
  def providers(options ={})
    options.merge!(:method => :InstancesOf, :instance => "__Win32Provider")
    instances_of(options).
    map{ |provider| provider.name }.compact
  end
  alias :providers_of :providers

  # Returns an array containing all the WMI namespaces
  # on a sytem.  Defaults to localhost
  #
  #   WMI.namespaces
  #
  #  For a more human readable version of namespaces when using options:
  #
  #   WMI.namespaces_of(:host => :some_computer)
  #
  #   WMI.namespaces_of(:namespace => "root\\Microsoft")
  def namespaces(options ={})
    options.merge!(:method => :InstancesOf, :instance => "__NAMESPACE")
    options[:namespace] ||= 'root'
    instances_of(options).
    map{ |namespace|
      namespace = "#{options[:namespace]}\\#{namespace.name}"
      ns = namespaces(options.merge(:namespace => namespace)) rescue nil
      [namespace, ns]
    }.flatten
  end
  alias :namespaces_of :namespaces

  def instances_of(options)
    Base.set_connection(options)
    conn = Base.send(:connection)
    items = namespaces = conn.send(options[:method], options[:instance])
    Base.send(:clear_connection_options)
    items
  end

  extend self

  def const_missing(name)
    self.const_set(name, Class.new(self::Base))
  end
end

# Alias for {RubyWMI}
WMI = RubyWMI
