class TagsParser
  def self.get_tags(html_doc,tags_to_collect)
    millivis_addr = html_doc.xpath("/html/body/table/tr[2]/td/table/tr/td[2]/div/p/a[1]")[0]['href']
    html_doc = Nokogiri::HTML(open(URI.encode("http://www.althingi.is#{millivis_addr}")))
    (html_doc/"div.FyrirsognMidSv").each do |top|
       if top.text.index("Efnisorð")
         next_sibling = top.next_sibling
         while (next_sibling.inspect[0..6]=="<a href")
           tags_to_collect << next_sibling.text.gsub(", "," og ")
           next_sibling=next_sibling.next_sibling.next_sibling.next_sibling
         end
       end
     end
     puts tags_to_collect.inspect
     tags_to_collect.join(", ")
  end
end
