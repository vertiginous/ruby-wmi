require 'wmi'
#~ require 'active_support'



properties = ['Description','MaxCapacity','MemoryDevices','MemoryErrorCorrection'] 


mem = Win32::PhysicalMemoryArray.find(:all, :host => 'zstlecap001')
mem.each{|i| puts properties.map{|p| "#{p}: #{i[p]}"}}

mem2 = Win32::PhysicalMemoryArray.find(:all, {:host => 'zstlecap003', :credentials => 
  {:user => 'disney\\gthiesfeld', :passwd => 'Britches!'} 
  }
 )
mem2.each{|i| puts properties.map{|p| "#{p}: #{i[p]}"}}


p WMI::subclasses_of :host => 'zstlecap001'