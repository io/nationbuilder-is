def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end

doc = get_file_as_string("breytingartillaga3.html")

doc = doc.gsub("&nbsp;", " ")

# Using regular expressions to find text for each node of Gx, GxMx and GxMxLx
header_element = nil; paragraph_element = nil
doc.to_s.scan(/\[(.*?)\] -->(.*?)(<!-- Para Num \d|<DL>|<\/HTML>)/m) do |match|
  puts match.inspect
  puts "\n\n"
  # id = match[0]
  # body = match[1]
  # 
  # # Find headers
  # id.scan(/G\d+$/) do |element_match|
  #   header_element = new_element(body, nil, process_document, TYPE_HEADER_MAIN_ARTICLE)
  # end
  # 
  # # Find paragraphs
  # id.scan(/G(\d+)M(\d+)$/) do |element_match|
  #   # puts "=====================================================================\n"
  #   # puts "#{header_element} #{id}\n"
  #   # puts "=====================================================================\n"
  #   # puts Nokogiri::HTML(body).text + "\n"
  #   # puts "\n\n"
  #   paragraph_element = new_element(body, header_element, process_document, TYPE_MAIN_ARTICLE)
  # end
  # 
  # # Find lists
  # id.scan(/G(\d+)M(\d+)L(\d+)$/) do |element_match|
  #   # puts "=====================================================================\n"
  #   # puts "#{header_element} #{paragraph_element} #{id}\n"
  #   # puts "=====================================================================\n"
  #   # puts Nokogiri::HTML(body).text + "\n" # TYPE_MAIN_ARTICLE
  #   # puts "\n\n"
  #   list_element = new_element(body, paragraph_element, process_document, TYPE_MAIN_ARTICLE)
  # end
  # 
  # # # body "<!-- #{id} --> #{body}"
  # # 
  # # puts "=====================================================================\n"
  # # puts id + "\n"
  # # puts "=====================================================================\n"
  # # puts Nokogiri::HTML(body).text + "\n"
  # # puts "\n\n"
end

