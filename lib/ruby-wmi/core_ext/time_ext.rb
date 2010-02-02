class Time
  
  def to_swbem_date_time
    t = strftime("%Y%m%d%H%M%S")
    o = gmt_offset/60
    "#{t}.000000#{o}" 
  end

  def self.parse_swbem_date_time(string)
    dt = /(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)\.(\d+)([+-]\d\d\d)/.match(string)
    local($1,$2,$3,$4,$5,$6)
  end
   
end