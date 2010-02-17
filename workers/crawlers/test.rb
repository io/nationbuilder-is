#RAILS_ENV='production'
RAILS_ENV='development'

require '../../config/boot'
require "#{RAILS_ROOT}/config/environment"

process_document = ProcessDocument.find(158)
# elements = process_document.process_document_elements

process_document.process_document_elements.articles.each { |article|
  article.children.each { |element|
    blah = element.sentences.map { |s| s.body }
    puts blah.inspect
    puts "\n\n"
  }
}
