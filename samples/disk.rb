require 'wmi'

disks = Win32::LogicalDisk.find(:all)

disks.each do |disk|
 disk.properties_.each do |p|
    puts "#{p.name}: #{disk[p.name]}"
  end
end