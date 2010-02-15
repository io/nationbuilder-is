class UidiffController < ApplicationController

  def index
  end

  def preview
    @actions = []
    @@last_element = nil
    @@last_character_index = 0
    @@next_character_index = 0

    # Get all objects
    @priority = Priority.find(45)
    @law = ProcessDocument.find(155)
    @proposal = ProcessDocument.find(84)

    # Put the original law document elements into an array
    @law_elements = []

    @law.process_document_elements.articles.each { |article|
      paragraph_index = 0

      # Paragraphs
      article.children.each { |element|
        sub_paragraph_index = 0
        paragraph_index += 1
        article_id = article.content_text_only.to_i
        @law_elements[article_id] = [] unless @law_elements[article_id]
        @law_elements[article_id][paragraph_index] = [] unless @law_elements[article_id][paragraph_index]
        @law_elements[article_id][paragraph_index][0] = {
        # @law_elements << {
          # :gr => article.content_text_only.to_i,
          # :mgr => paragraph_index,
          # :tolul => 0,
          :text => element.content_text_only,
          :sentences => text_to_sentence(element.content_text_only)
        }
        # Töluliðir
        element.children.each { |sub_element|
          sub_paragraph_index += 1
          article_id = article.content_text_only.to_i
          @law_elements[article_id][paragraph_index][sub_paragraph_index] = {
          # @law_elements << {
          #   :gr => article.content_text_only.to_i,
          #   :mgr => paragraph_index,
          #   :tolul => sub_paragraph_index,
            :text => sub_element.content_text_only,
            :sentences => text_to_sentence(element.content_text_only)
          }
        }
      }
    }

    # Put the proposal document elements into an array
    elements = []

    @proposal.process_document_elements.articles.each { |article|
      article.children.each { |element|
        elements << element.content_text_only
      }
    }

    # Parse the elements and create a hash
    parts = {}

    for element in elements
      lines = element.split("\n")
      for line in lines
        # Við 3. mgr. bætist nýr málsliður sem orðast svo:
        line.gsub!(/(.*?)(bætist)(.*?)(orðast svo)(.*?)(:)/) { |match| parse_element(:add_new, match, element, parts) }

        # 1. gr. laganna orðast svo:
        line.gsub!(/(.)(.*?)(orðast svo)(.*?)(:)/) { |match| parse_element(:replace_all, match, element, parts) }

        # 3. og 4 gr. laganna falla brott
        line.gsub!(/(.)(.*?)(fellur brott)(.*?)/) { |match| parse_element(:remove, match, element, parts) }
        line.gsub!(/(.)(.*?)(falla brott)(.*?)/) { |match| parse_element(:remove, match, element, parts) }

        # Eftirfarandi breytingar verða á 6. gr. laganna:
        line.gsub!(/(.*?)(breytingar)(.*?)(gr\.)(.*?)(:)/) { |match| parse_element(:change, match, element, parts) }
      end
    end

    # We need to process the last text element outside the loop
    find_text

    for action in @actions
      puts action.inspect
      puts "\n\n"
    end
  end







  private

  # Replace those weird little Icelandic characters with standard ones

  def replace_weird_characters(text)
    pattern1 = ["Á", "á", "Ð", "ð", "É", "é", "Í", "í", "Ó", "ó", "Ú", "ú", "Ý", "ý", "Þ", "þ", "Æ", "æ", "Ö", "ö"]
    pattern2 = ["a", "a", "d", "d", "e", "e", "i", "i", "o", "o", "u", "u", "y", "y", "th", "th", "ae", "ae", "o", "o"]

    pattern1.each_with_index { |char,index| text.gsub!(char, pattern2[index]) }

    text
  end

  # Split text into sentences

  def text_to_sentence(text)
    text.split(".")

    # sentences = text.to_iso.split(".")
    # sentences.each_with_index { |sentence,key|
    #   sentences[key] += "."
    #   sentence.strip!
    #   sentences[key] += "||#{sentence[0].chr}||" if sentence[0]
    #   if sentence[0] and sentence[0].chr.downcase == sentence[0].chr
    #     sentences[key-1] += sentence
    #     sentences.delete_at(key)
    #   end
    # }
    # 
    # sentences.each_with_index { |sentence,key| sentences[key] = sentences[key].to_utf8 }
    # 
    # sentences
    # # sentences1 = text.split(".")
    # # sentences2 = []
    # # # text.scan(/[A-Z](.*)(\. )[A-Z]/) { |match| sentences << match }
    # # 
    # # sentences1.each { |sentence|
    # #   sentences2 
    # # }
    # # 
    # # sentences2
  end

  # Search for "x. gr.", "x. og x. gr.", "x. málsl.", "x. tölul.", "x. mgr."

  def find_parts(action, parts, text)
    # Reset everything but "gr."
    parts.each { |key, value| parts.delete(key) if key != :gr }

    # Set the action
    parts[:action] = action

    # Search for parts:
    #   (\d{1,3}) = 1-3 digits (1)
    #   dot
    #   ((\s|\.|\,|\d{1,3}|og)*) = multiple occurrences of whitespace, dot, comma, 1-3 digits, "og" (2., 3. og 4.)
    #   space
    #   (gr\.|málsl\.|tölul\.|mgr\.) = one of the following: "gr.", "málsl.", "tölul.", "mgr."
    text.scan(/(\d{1,3}).((\s|\.|\,|\d{1,3}|og)*) (gr\.|málsl\.|tölul\.|mgr\.)/) { |match|
      values = []
      values << match[0]
      match[1].scan(/(\d{1,3})./) { |smatch| values << smatch[0] }
      parts[replace_weird_characters(match[3]).gsub!(".","").to_sym] = values
    }

    # Add the results to the main actions array
    @actions << parts.clone
  end

  def find_text(match = nil, element = nil)
    action_index = 2

    if match
      @@next_character_index = element.index(match) + match.length
      text = element[@@last_character_index..@@next_character_index - match.length]
      text = @@last_element[@@last_character_index..@@last_element.length] if ((text and text.strip.empty?) or !text) and @@last_element
      @@last_character_index = @@next_character_index
    else
      text = @@last_element[@@last_character_index..@@last_element.length]
      action_index = 1
    end

    @actions[@actions.length-action_index][:new_text] = text unless [:change, :remove].include?(@actions[@actions.length-action_index][:action])
    @@last_element = element
  end

  def parse_element(action, match, element, parts)
    # MUNA AÐ LEITA EFTIR "ásamt fyrirsögn"
    find_parts(action, parts, match)
    find_text(match, element)
    ""
  end

  # def parse_add_new(match, element, parts)
  #   # MUNA AÐ LEITA EFTIR "ásamt fyrirsögn"
  #   find_parts(:add_new, parts, match)
  #   find_text(match, element)
  #   ""
  # end
  # 
  # def parse_change(match, element, parts)
  #   find_parts(:change, parts, match)
  #   find_text(match, element)
  #   ""
  # end
  # 
  # def parse_remove(match, element, parts)
  #   find_parts(:remove, parts, match)
  #   find_text(match, element)
  #   ""
  # end
  # 
  # def parse_replace_all(match, element, parts)
  #   # MUNA AÐ LEITA EFTIR "ásamt fyrirsögn"
  #   find_parts(:replace_all, parts, match)
  #   find_text(match, element)
  #   ""
  # end

end
