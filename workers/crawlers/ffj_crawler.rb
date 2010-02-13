require 'rubygems'
gem 'nokogiri', '=1.3.3'; require 'nokogiri'
require 'open-uri'

RAILS_ENV='development'

require '../../config/boot'
require "#{RAILS_ROOT}/config/environment"


DEBUG=1

# Titill (Haus+texti)
# - Kafli (Haus+texti)
# -- Gr (Haus)
# --- Málsgrein (Texti)
# ---- Töluliður (Texti)


# # Dæmi um að fá núverandi lagaúmer
# if law_number = "Lög um breytingu á lögum nr. 96/2009, um heimild nr. 233/3234 til handa fjármálaráðherra, fyrir hönd ríkissjóðs, til að ábyrgjast lán Tryggingarsjóðs innstæðueigenda og fjárfesta frá breska og hollenska ríkinu til að standa straum af greiðslum til innstæðueigenda hjá Landsbanka Íslands hf.".scan(/nr. (\d{1,3})\/(\d{4})/o).first
#   law_id = law_number[0]
#   law_year = law_number[1]
#   law_id = "0" + law_id if law_id.size < 3
#   puts law_now = law_year + law_id
# end
# # Dæmi endar
# 
# # Sækja númer á núverandi lögum
# html_doc = Nokogiri::HTML(open('http://www.althingi.is/altext/138/s/0193.html'))
# law_now = html_doc.xpath("//div[(((count(preceding-sibling::*) + 1) = 9) and parent::*)]//b").to_s.scan(/nr. (\d{1,3})\/(\d{4})/o).first

# Sækja og splitta upp núverandi lögum
law_now = '2006116'
doc = Nokogiri::HTML(open("http://www.althingi.is/lagas/nuna/#{law_now}.html"))
title = doc.css("h2").text

# # Find all the chapters
# chapters = []
# doc.css("b").each do |b|
#   b.text.scan(/. kafli./o) { |match| chapters << b.text }
# end
# puts chapters if DEBUG

# doc.search("//b/following-sibling::text()|//b/preceding-sibling::text()").each do |node|
#   puts node
# end

# # Find all the nodes for Gx, GxMx and GxMxLx
# # From http://stackoverflow.com/questions/649963/nokogiri-searching-for-div-using-xpath
# full_regex = %r([0-9]+)
# full_regex = %r(<a name=(.*)>(.*))
# filter_by_name = Class.new do
#   attr_accessor :matches
# 
#   def initialize(regex)
#     @regex = regex
#     @matches = []
#   end
# 
#   def filter(node_set)
#     @matches += node_set.find_all { |x| x['name'] =~ @regex }
#   end
# end.new(full_regex)
# 
# doc.css("a:filter()", filter_by_name)
# filter_by_name.matches.each do |node|
#   puts node
#   puts "="*100
# end

# Using XPath following-sibling and preceding-sibling
# doc.search("//a[name]/following-sibling::text()|//br/preceding-sibling::text()").each do |node|
# #doc.search("//a/following-sibling::text()|//a/following-sibling::img").each do |node|
#   puts node
#   puts '===================='
# end

# From http://wiki.github.com/tenderlove/nokogiri/examples
# if body = doc.css('body') then
#   stack = []
#   chapters = []
#   body.children.each do |node|
#   #   # non-matching nodes will get level of 0
#   #   level = node.name[ /a/i, 1 ].to_i
#   #   level = 99 if level == 0
#   # 
#   #   stack.pop while (top=stack.last) && top[:level]>=level
#   #   stack.last[:div].add_child( node ) if stack.last
#   #   if level<99
#   #     div = Nokogiri::XML::Node.new('div',@nokodoc)
#   #     div.set_attribute( 'class', 'section' )
#   #     node.add_next_sibling(div)
#   #     stack << { :div=>div, :level=>level }
#   #   end
#     # node.text.scan(/I. kafli./) { |match| chapters << node.text }
#     puts node
#     puts '============================================='
#   end
#   # puts chapters
# end

# Using regular expressions to find text for each node of Gx, GxMx and GxMxLx
doc.to_s.scan(/me="(.*?)">(.*?)(<a na|<\/html>)/m) do |match|
  id = match[0]
  body = match[1]

  # body "<!-- #{id} --> #{body}"
  
  puts "=====================================================================\n"
  puts id + "\n"
  puts "=====================================================================\n"
  puts Nokogiri::HTML(body).text + "\n"
  puts "\n\n"
end
