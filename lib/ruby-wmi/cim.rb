module CIM
  extend WMI
  
  class Base < WMI::Base
    class << self
      def subclass_name
        self.name.gsub('::', '_')
      end
    end
  end
  
end