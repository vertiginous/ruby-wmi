module RubyWMI
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
end
