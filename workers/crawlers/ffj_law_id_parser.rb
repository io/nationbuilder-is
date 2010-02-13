require 'rubygems'
gem 'nokogiri', '=1.3.3'; require 'nokogiri'
require 'open-uri'


# url = "http://www.althingi.is/altext/138/s/0012.html" # Virkar
#url = "http://www.althingi.is/altext/138/s/0005.html" # Virkar EKKI þar sem þetta er ekki í hausnum
# url = "http://www.althingi.is/altext/138/s/0016.html" # Virkar EKKI þar sem þetta er rangt skilgreint í haus
url = "http://www.althingi.is/altext/138/s/0292.html"

doc = Nokogiri::HTML(open(url))
if law_number = doc.text.scan(/nr. (\d{1,3})(.*)(\d{4})/o).first
  law_id = law_number[0]
  law_year = law_number[2]
  law_id = "0" + law_id if law_id.size < 3
  law_now = law_year + law_id
end

puts law_now