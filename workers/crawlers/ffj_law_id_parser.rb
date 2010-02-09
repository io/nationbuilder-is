require 'rubygems'
gem 'nokogiri', '=1.3.3'; require 'nokogiri'
require 'open-uri'


#url = "http://www.althingi.is/altext/138/s/0012.html" # Virkar
#url = "http://www.althingi.is/altext/138/s/0005.html" # Virkar EKKI þar sem þetta er ekki í hausnum
url = "http://www.althingi.is/altext/138/s/0016.html" # Virkar EKKI þar sem þetta er rangt skilgreint í haus

doc = Nokogiri::HTML(open(url))
if law_number = doc.text.scan(/nr. (\d{1,2})(.*)(\d{4})|nr. (\d{1,3})\/(\d{4})/o).first
  if law_number.size < 3 # If the format is nr. 116/2006
    law_id = law_number[0] # 116
    law_year = law_number[1] # 2006
  else # Else if the format is nr. 19 12. febrúar 1940
    law_id = law_number[0] # 19
    law_year = law_number[2] # 1940 
  end
  law_id = "0" + law_id if law_id.size < 3
  law_now = law_year + law_id
end

puts law_now