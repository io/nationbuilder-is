# Copyright (C) 2008,2009,2010 Róbert Viðar Bjarnason
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

ORIGINAL_LAW_TYPE_HEADER_CHAPTER = 1
ORIGINAL_LAW_TYPE_HEADER_MAIN_ARTICLE = 2
ORIGINAL_LAW_TYPE_HEADER_MAIN_PARAGRAPH = 3
ORIGINAL_LAW_TYPE_HEADER_PARAGRAPH_LIST = 4

class LawOriginalDocumentElement < ProcessDocumentElement

  def parent
    ProcessDocumentElement.find(self.parent_id) if self.parent_id
  end
  
  def content_type_s
    case self.content_type
      when 1 then "ORIGINAL_LAW_TYPE_HEADER_CHAPTER"
      when 2 then "ORIGINAL_LAW_TYPE_HEADER_MAIN_ARTICLE"
      when 3 then "ORIGINAL_LAW_TYPE_HEADER_MAIN_PARAGRAPH"
      when 4 then "ORIGINAL_LAW_TYPE_HEADER_PARAGRAPH_LIST"
      else "UNKNOWN"
    end
  end
  
  def set_content_type_for_header    
  end
      
  def set_content_type_for_main_content
  end

  def is_main_header?
    self.sequence_number==1
  end

  def is_chapter_header?
    content.downcase =~ /kafli/
  end
  
  def self.create_elements(doc, process_id, process_document_id, url, process_type)
    puts "GET ORIGINAL LAW DOCUMENT HTML FOR: #{url} process_document: #{process_document_id} process_type: #{process_type}"
    html_source_doc = nil
    retries = 10

    begin
      Timeout::timeout(120){
        html_source_doc = Nokogiri::HTML(open(url))
      }
    rescue
      retries -= 1
      if retries > 0
        sleep 0.42 and retry
        puts "retry"
      else
        raise
      end
    end

    if html_source_doc.text.index("Vefskjalið er ekki tilbúið")
      puts "ProcessDocument not yet ready"
      return nil
    end

    if ProcessDocument.find_by_external_link(url)
      puts "Found document at: #{url}"
      return nil
    end
    
    doc.priority_process_id = process_id
    doc.process_document_id = process_document_id
    #doc.category_id = 1
    doc.process_document_state_id = 1
    doc.process_document_type_id = 1
    doc.external_link = url
    doc.voting_close_time = Time.now+1.month
    doc.original_version = true
    doc.save

    elements = []
    sequence_number = 0

    process_document_id = doc.id
    
    div_skip_count = 0

    if law_number = html_source_doc.xpath('//font//a').scan(/nr. (\d{1,3})\/(\d{4})/).first
      law_id = law_number[0]
      law_year = law_number[1]
      law_id = "0" + law_id if law_id.size < 3
      law_now = law_year + law_id
    end

    html_source_doc.xpath('//div').each do |paragraph|
      #TBD
    end

    for element in elements
      puts "Element sequence number: #{element.sequence_number}"
      puts "Element content type: #{element.content_type_s} - #{element.content_type}"
      puts "Element content number: #{element.content_number}"
      puts "#{element.content_text_only}"
      puts "---------------------------------------------------------------------------------"
    end
    
    puts "HTML"
    
    for element in elements
      puts "#{element.content}"
    end
    exit
    return doc
  end  
end