require 'ruby-wmi'

describe "Time" do

  describe "to_swbem_date_time" do
    it "should return an SWbemDateTime string" do
      t = Time.local(2010,2,1,10,22)
      t.to_swbem_date_time.should eql("20100201102200.000000-360")
    end
  end

  describe "parse_swbem_date_time" do
  
    it "should parse a swbemdatetime string" do
      wbem = Time.parse_swbem_date_time("20100201102200.000000-360")
      wbem.to_s.should eql("Mon Feb 01 10:22:00 -0600 2010")
    end

  end

end