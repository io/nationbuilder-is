require "enumerator"
require "htmlentities"

class Combiner

  #
  # ------------------------------------------------------
  # Phase 1 - Split the source elements into arrays
  # ------------------------------------------------------
  # 

  # Put document elements into an array
  def put_law_document_elements_into_array(law_document)
    elements = []

    # Iterate through the document elements
    law_document.process_document_elements.articles.each { |article|
      paragraph_index = 0
    
      # Paragraphs
      article.children.each { |element|
        sub_paragraph_index = 0
        paragraph_index += 1
        article_id = article.content_text_only.to_i
        elements[article_id] = [] unless elements[article_id]
        elements[article_id][paragraph_index] = [] unless elements[article_id][paragraph_index]
        elements[article_id][paragraph_index][0] = {
          :text => element.content_text_only,
          :sentences => element.sentences.map { |s| s.body }
        }
        # Töluliðir
        element.children.each { |sub_element|
          sub_paragraph_index += 1
          article_id = article.content_text_only.to_i
          elements[article_id][paragraph_index][sub_paragraph_index] = {
            :text => sub_element.content_text_only,
            :sentences => sub_element.sentences.map { |s| s.body }
          }
        }
      }
    }

    elements
  end

  # # Put the proposal document elements into an array
  # def put_proposal_document_elements_into_array(proposal_document)
  #   elements = []
  # 
  #   proposal_document.process_document_elements.articles.each { |article|
  #     article.children.each { |element|
  #       elements << element.content_text_only.gsub(/^(.*?):(.*?):(.*?)$/) { |match| # Hugsanlega dugar ^(.*?):$
  #         # Replace all ":" but first, in each line, with $$colon$$, which will then be replaced back to ":" once parsing is done
  #         result = ""
  #         match.scan(/^(.*?)(:)(.*?)(:)(.*?)$/) { |matches|
  #           result = matches[0] + ":"
  #           matches[2..matches.length-2].each { |m| result += (m == ":") ? "$$colon$$" : m }
  #         }
  #         result
  #       }
  #     }
  #   }
  # 
  #   elements
  # end

  # Put the generated (saved) proposal document elements into an array
  def put_generated_proposal_document_elements_into_array(generated_proposal_document)
    elements = []
    coder = HTMLEntities.new

    generated_proposal_document.generated_proposal_elements.each { |gpe|
      content = gpe.process_document_element.content_text_only.blank? ? coder.decode(gpe.process_document_element.content.gsub("<br />", "\n")) : gpe.process_document_element.content_text_only
      elements << content.gsub(/^(.*?):(.*?):(.*?)$/) { |match| # Hugsanlega dugar ^(.*?):$
        # Replace all ":" but first, in each line, with $$colon$$, which will then be replaced back to ":" once parsing is done
        result = ""
        match.scan(/^(.*?)(:)(.*?)(:)(.*?)$/) { |matches|
          result = matches[0] + ":"
          matches[2..matches.length-2].each { |m| result += (m == ":") ? "$$colon$$" : m }
        }
        result
      }
    }

    elements
  end

  # Generate an array of combination actions
  def generate_actions(elements)
    @@actions = []
    @@last_element = nil
    @@last_character_index = 0
    @@next_character_index = 0

    # Parse the elements and create a hash
    parts = {}

    for element in elements

      lines = element.split(/\n/)
      for line in lines
        found = false
        # Við 3. mgr. bætist nýr málsliður sem orðast svo:
        line.gsub!(/(.*?)(bætist)(.*?)(orðast svo|orðist svo|svohljóðandi)(.*?)(:)/) { |match| parse_element(:add_new, match, element, parts); found = true }
        next if found
        
        # 1. gr. laganna orðast svo:
        line.gsub!(/(.)(.*?)(orðast svo|orðist svo)(.*?)(:)/) { |match| parse_element(:replace_all, match, element, parts); found = true }
        next if found

        # 3. og 4 gr. laganna falla brott
        line.gsub!(/([^:\n]*)(fellur brott|falla brott|falli brott)(.*?)/) { |match| parse_element(:remove, match, element, parts); found = true }
        next if found
        # line.gsub!(/(.)(.*?)(fellur brott|falla brott|falli brott)(.*?)/) { |match| parse_element(:remove, match, element, parts) }
        # line.gsub!(/(.)(.*?)(falla brott)(.*?)/) { |match| parse_element(:remove, match, element, parts) }
        
        # Eftirfarandi breytingar verða á 6. gr. laganna:
        line.gsub!(/(.*?)(breytingar)(.*?)(gr\.)(.*?)(:)/) { |match| parse_element(:change, match, element, parts); found = true }
        next if found

        # Við 6. gr. ...
        line.gsub!(/(.*)(Við )(\d{1,3}). (gr\.)/) { |match| parse_element(:change, match, element, parts); found = true }
        next if found
        
        # Í stað hlutfallstölunnar „33%“ í 3. mgr. kemur: 15%.
        line.gsub!(/Í stað(.*?)„(.*?)“(.*?)(:)/) { |match| parse_element_replace_inline(match, element, parts); found = true }
        next if found
      end
    end

    # We need to process the last text element outside the loop
    find_text

    # # Make sure there are no duplicate actions
    # @@actions_copy = @@actions.clone.reverse.each { |action| action.delete("action"); action.delete("new_text") }
    # 
    # @@actions_copy.each_with_index { |action, index|
    #   @@actions.delete_at(index) if @@actions_copy.include?(action)
    # }

    # Return the actions
    @@actions
  end

  # Replace those weird little Icelandic characters with standard ones
  def replace_weird_characters(text)
    pattern1 = ["Á", "á", "Ð", "ð", "É", "é", "Í", "í", "Ó", "ó", "Ú", "ú", "Ý", "ý", "Þ", "þ", "Æ", "æ", "Ö", "ö"]
    pattern2 = ["a", "a", "d", "d", "e", "e", "i", "i", "o", "o", "u", "u", "y", "y", "th", "th", "ae", "ae", "o", "o"]

    pattern1.each_with_index { |char,index| text.gsub!(char, pattern2[index]) }

    text
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

    # Search for parts:
    #   ([A-Z]) = 1 uppercase letter (A)
    #   dash
    #   (liður)
    text.scan(/([A-Z])-(liður)/) { |match|
      values = []
      # values << match
      values << match[0]
      # match[1].scan(/([A-Z])-/) { |smatch| values << smatch[0] }
      parts[replace_weird_characters(match[1]).to_sym] = values
    }

    # Add the results to the main actions array
    @@actions << parts.clone
  end

  # Find the text that follows each action part
  def find_text(match = nil, element = nil)
    action_index = 2

    if match
      @@next_character_index = element.index(match) + match.length
      text = element[@@last_character_index..@@next_character_index - match.length]
      text = @@last_element[@@last_character_index..@@last_element.length] if ((text and text.strip.empty?) or !text) and @@last_element
      @@last_character_index = @@next_character_index
    else
      text = @@last_element[@@last_character_index..@@last_element.length] if @@last_element
      action_index = 1
    end

    # Remove unwanted stuff from the text
    text = text.gsub(" ", " ") if text # FIXME: DO NOT EDIT THIS LINE, find a better way to replace that strange character (ascii 194 = Â)
    text = text.gsub(/(\W)([a-z]\.)(.*)/m, "") if text

    # Update the actions array
    @@actions[@@actions.length-action_index][:new_text] = text unless @@actions.blank? or [:change, :remove].include?(@@actions[@@actions.length-action_index][:action])
    @@last_element = element
  end

  def parse_element(action, match, element, parts)
    # puts "$$#{action}$$ #{match.inspect}"
    # puts "\n\n"
    # MUNA AÐ LEITA EFTIR "ásamt fyrirsögn"
    find_parts(action, parts, match)
    find_text(match, element)
    ""
  end

  def parse_element_replace_inline(match, element, parts)
    find_parts(:replace_inline, parts, match)
    find_text(match, element)
    match.scan(/„(.*?)“/) { |m| @@actions[@@actions.length-1][:inline_text] = m[0] }
    ""
  end


  #
  # ------------------------------------------------------
  # Phase 2 - Render the final law document
  # ------------------------------------------------------
  # 

  # Use the generated actions to make changes to the document elements
  def render_law(law_elements, actions)
    old_text = ""

    for action in actions
      if action[:gr]
        # Articles (greinar)
        action[:gr].each { |article|
          if action[:mgr]
            # Articles with paragraphs (málsgreinar)
            action[:mgr].each { |paragraph|
              if action[:tolul]
                # Paragraphs with list items (töluliðir)
                action[:tolul].each { |item|
                  old_text = parse_text(action, :tolul, law_elements, article.to_i, paragraph.to_i)
                }
              else
                # Paragraphs without list items (töluliðir)
                old_text = parse_text(action, :mgr, law_elements, article.to_i)
              end
            }
          else
            # Articles without paragraphs (málsgreinar)
            old_text = parse_text(action, :gr, law_elements)
          end
        }
      end
    end

    # Return the old text, only as reference
    old_text
  end

  # Parse each part of a document element
  def parse_text(action, element_type, law_elements, article_id = 0, paragraph_id = 0, item_id = 0)
    results = []
    sentences = []
    old_text = ""
    elements = action[element_type]

    elements.each { |element_id|
      case element_type
      when :gr
        article_id = element_id.to_i
        paragraph_id = law_elements[article_id].length-1 if paragraph_id == 0
      when :mgr
        paragraph_id = element_id.to_i
      when :tolul
        item_id = element_id.to_i
      end

      if law_elements[article_id]
        if law_elements[article_id][paragraph_id]
          if law_elements[article_id][paragraph_id][item_id]
            law_element_sentences = law_elements[article_id][paragraph_id][item_id][:sentences]
            sentences = action[:malsl] ? action[:malsl] : (law_element_sentences ? law_element_sentences.enum_with_index.map { |x,i| i+1 } : [])

            sentences.each { |sentence_id|
              results = parse_action(action, law_element_sentences[sentence_id.to_i-1])
              law_element_sentences[sentence_id.to_i-1] = results[:old_text] if results and not results[:old_text].blank?
              old_text = "#{old_text}#{results[:old_text]}"
            }

            law_element_sentences[sentences.last.to_i-1] += results[:new_text] if results and not results[:new_text].blank?
          end
        end
      end
    }

    old_text
  end

  # Determing new text on each document element based on the type of action
  def parse_action(action, law_element)
    old_text = ""
    new_text = ""

    case action[:action]
    when :add_new
      new_text = "<span class=\"new-sentence\">#{action[:new_text]}</span>"
    when :remove
      old_text = "<span class=\"removed-sentence\">#{law_element.clone}</span>"
    when :replace_all
      old_text = "<span class=\"replaced-sentence\">#{law_element.clone}</span>"
      new_text = "<span class=\"new-sentence\">#{action[:new_text]}</span>"
    when :replace_inline
      old_text = law_element.clone.gsub(action[:inline_text], "<span class=\"replaced-sentence\">#{action[:inline_text]}</span><span class=\"new-sentence\">#{action[:new_text]}</span>") if action[:inline_text]
    end

    { :old_text => old_text, :new_text => new_text }
  end

end