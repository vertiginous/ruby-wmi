require 'ruby-wmi'

def get_wql(klass, options={})
  klass.send(:construct_finder_sql, options)
end

class WmiSpec < WMI::Base
  set_wmi_class_name "Win32_Something"
end

describe 'construct_finder_sql' do

  it 'should return a sql string' do
    wql = "SELECT * FROM Win32_Something"
    get_wql(WmiSpec).should eql(wql)
  end

  it 'should return a sql string with conditions' do
    wql = "SELECT * FROM Win32_Something WHERE DriveType = '3' AND Caption = 'C:'"
    get_wql(WmiSpec, :conditions => {:drive_type => 3, :caption => 'C:'}).should eql(wql)
  end
  
  it 'should return a sql string with conditions' do
    wql = "SELECT * FROM Win32_Something WHERE DriveType = '3'"
    get_wql(WmiSpec, :conditions => {:drive_type => 3}).should eql(wql)
  end
  
  it 'should return a sql string with conditions' do
    wql = "SELECT * FROM Win32_Something WHERE DriveType = '3'"
    get_wql(WmiSpec, :conditions => ['DriveType = %s', 3]).should eql(wql)
  end

  it 'should return a sql string with conditions' do
    wql = "SELECT * FROM Win32_Something WHERE DriveType = '3'"
    get_wql(WmiSpec, :conditions => ['DriveType = ?', 3]).should eql(wql)
  end
 
  it 'should return a sql string with conditions' do
    wql = "SELECT * FROM Win32_Something WHERE DriveType = '3' AND Caption = 'C:'"
    get_wql(WmiSpec, :conditions => ['DriveType = ? AND Caption = ?', 3, "C:"]).should eql(wql)
  end 
  
  it 'should return a sql string with conditions' do
    wql = "SELECT * FROM Win32_Something WHERE FileSystem IS NULL"
    get_wql(WmiSpec, :conditions => {:file_system => nil}).should eql(wql)
  end

  it 'should return a sql string with conditions' do  
    wql = "SELECT * FROM Win32_Something WHERE TimeWritten >= '20100403091237.000000-300' AND TimeWritten < '20100410091237.000000-300'"
    date_range = Time.local(2010,4,3,9,12,37)...Time.local(2010,4,10,9,12,37)
    get_wql(WmiSpec, :conditions => {:time_written => date_range}).should eql(wql)
  end
    
  it 'should return a sql string with conditions' do  
    wql = "SELECT * FROM Win32_Something WHERE TimeWritten >= '20100403091237.000000-300' AND TimeWritten <= '20100410091237.000000-300'"
    date_range = Time.local(2010,4,3,9,12,37)..Time.local(2010,4,10,9,12,37)
    get_wql(WmiSpec, :conditions => {:time_written => date_range}).should eql(wql)
  end
  
  it 'should return a sql string with conditions' do
    wql =  "SELECT * FROM Win32_Something WHERE Drivetype >= '3' AND Drivetype <= '5'"
    get_wql(WmiSpec, :conditions => {:drivetype => 3..5}).should eql(wql)
  end
  
  it 'should return a sql string with conditions' do
    wql =  "SELECT * FROM Win32_Something WHERE Drivetype >= '3' AND Drivetype < '5'"
    get_wql(WmiSpec, :conditions => {:drivetype => 3...5}).should eql(wql)
  end
  
  it 'should return a sql string with a select string' do
    wql = "SELECT Name FROM Win32_Something"
    get_wql(WmiSpec, :select => :name).should eql(wql)
  end

  it 'should return a sql string with a select array' do
    wql = "SELECT Name, Caption FROM Win32_Something"
    get_wql(WmiSpec, :select => [:name, :caption]).should eql(wql)
  end

end