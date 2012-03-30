require 'ruby-wmi'

describe Time do
  let(:offset) { Time.local(2010).gmt_offset/60 }

  describe "to_swbem_date_time" do
    it "should return an SWbemDateTime string" do
      t = Time.local(2010,2,1,10,22)
      t.to_swbem_date_time.should eql("20100201102200.000000#{offset}")
    end
  end

  describe "parse_swbem_date_time" do
    it "should parse a swbemdatetime string" do
      wbem = Time.parse_swbem_date_time("20100201102200.000000#{offset}")
      wbem.to_s.should eql("2010-02-01 10:22:00 -0800")
    end
  end
end
