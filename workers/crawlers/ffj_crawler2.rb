require 'rubygems'
gem 'nokogiri', '=1.3.3'; require 'nokogiri'
require 'open-uri'

RAILS_ENV='development'

require '../../config/boot'
require "#{RAILS_ROOT}/config/environment"

require 'law_document_element'
require 'law_proposal_document_element'
require 'process_parser'
require 'tags_parser'

def get_original_law(id)
  process_document = ProcessDocument.find(id)
  elements = process_document.process_document_elements.all(:conditions => "content_type IN (1,18)")

  header = ""
  elements.each {|element| header += element.content_text_only.strip}

  # Find the current/original law number
  if law_number = header.scan(/nr. (\d{1,3})(.*)(\d{4})/o).first
    law_id = law_number[0]
    law_year = law_number[2]
    law_id = law_id.rjust(3,"0") # Law numbers should always be three letters
    law_now = law_year + law_id
  end

  # Crawl the current/original law
  doc, law_now, process_document = Nokogiri::HTML(open("http://www.althingi.is/lagas/nuna/#{law_now}.html")), law_now, process_document
end

def new_element(content, parent_element, process_document, content_type)
  e = LawProposalDocumentElement.new
  e.content = content
  e.content_text_only = content.gsub(/<\/?[^>]*>/, "")
  e.sequence_number = 1
  e.parent_id = parent_element.id if parent_element
  e.process_document = process_document
  e.content_type = content_type if content_type
  # e.set_content_type_for_main_content if parent_id
  e.original_version=true
  e.save(false)

  # Split text into sentences using IceNLP SrxSegmentizer
  if content_type == TYPE_MAIN_ARTICLE
    output = %x[echo "#{CGI::escape(e.content_text_only).gsub("+", " ").gsub(/"/, '\\"')}" | java -classpath srx/IceNLPCore.jar:srx/segment-1.3.3.jar:srx/commons-io-1.4.jar:srx/commons-logging-1.1.1.jar is.iclt.icenlp.core.tokenizer.SrxSegmentizer]
    output.split(/\n/).each do |sentence|
      s = Sentence.new
      s.process_document_element = e
      s.body = CGI::unescape(sentence.gsub(" ", "+"))
      s.save(false)
    end
  end
  e
end

#
# Get the original law
#
doc, law_now, process_document = get_original_law(142)

#
# Create new process document for the original law
#
process_document = ProcessDocument.new
process_document.sequence_number = 1
process_document.priority_process = process_document.priority_process #current_process.id
process_document.stage_sequence_number = 1
# process_document.external_date = ""
process_document.external_id = law_now
process_document.external_link = "http://www.althingi.is/lagas/nuna/#{law_now}.html"
process_document.external_type = "lög"
process_document.external_author = ""

# Using regular expressions to find text for each node of Gx, GxMx and GxMxLx
header_element = nil; paragraph_element = nil
doc.to_s.scan(/me="(.*?)">(.*?)(<a na|<\/html>)/m) do |match|
  id = match[0]
  body = match[1]

  # Find headers
  id.scan(/G\d+$/) do |element_match|
    header_element = new_element(body, nil, process_document, TYPE_HEADER_MAIN_ARTICLE)
  end
  
  # Find paragraphs
  id.scan(/G(\d+)M(\d+)$/) do |element_match|
    # puts "=====================================================================\n"
    # puts "#{header_element} #{id}\n"
    # puts "=====================================================================\n"
    # puts Nokogiri::HTML(body).text + "\n"
    # puts "\n\n"
    paragraph_element = new_element(body, header_element, process_document, TYPE_MAIN_ARTICLE)
  end

  # Find lists
  id.scan(/G(\d+)M(\d+)L(\d+)$/) do |element_match|
    # puts "=====================================================================\n"
    # puts "#{header_element} #{paragraph_element} #{id}\n"
    # puts "=====================================================================\n"
    # puts Nokogiri::HTML(body).text + "\n" # TYPE_MAIN_ARTICLE
    # puts "\n\n"
    list_element = new_element(body, paragraph_element, process_document, TYPE_MAIN_ARTICLE)
  end

  # # body "<!-- #{id} --> #{body}"
  # 
  # puts "=====================================================================\n"
  # puts id + "\n"
  # puts "=====================================================================\n"
  # puts Nokogiri::HTML(body).text + "\n"
  # puts "\n\n"
end

