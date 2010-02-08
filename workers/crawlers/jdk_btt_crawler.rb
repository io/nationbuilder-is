def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end

def split_line(line)
  # Strip HTML
  sline = line.gsub(/<\/?[^>]*>/,  "")
  # Convert &nbsp; to regular space
  sline.gsub!("&nbsp;", "")
  # Remove leading and trailing spaces
  sline.strip!
  # Check if the first two characters represent a list item
  # return (sline[1] and sline[1].chr == ".") ? sline[0..1] : false
  return (sline[0] and sline[1] and sline[0].chr.to_i > 0 and sline[1].chr == ".") ? sline[0..1] : false
end

def line_is_a_new_element(line)
  return split_line(line)
end

def break_apart(filename)
  last_element_start = ""
  first_found = false
  # parents = []
  text = ""
  last_title = ""
  title = ""
  partial = ""

  f = File.open(filename, "r") 

  f.each_line do |line|
    if element_start = line_is_a_new_element(line)
      first_found = true

      # Add the element
      unless title == ""
        text += "==========================================================================\n"
        text += "#{title}\n"
        text += "==========================================================================\n"
        text += partial
        text += "\n"
        text += "\n"
      end

      # Store the title that we just found
      title = element_start

      # # Indent if the title is "a"
      # parents.push(last_title) if title and title[0].chr == "a"
      # 
      # # Outdent if the ascii value of the title is less or equal than the last title
      # parents.pop if (title[0] and last_title[0]) and ((title[0].chr.to_i == title[0].chr.to_s) or (title[0].chr != "a" and title[0] <= last_title[0]))
      # 
      # # Remove all indentation if the title is an integer
      # parents = [] if title[0].chr.to_i == title[0].chr

      # Store the rest of the line
      partial = line[line.index(element_start)+2..line.length]

      # Store the title
      last_title = title
    else
      partial += line if first_found
    end

    # Search for ordered list index
    # line.gsub!(/(<!-- Para Num )(.*?)( \[)(.*?)(\] -->)(.*?)(<!-- Para Num End -->)/) { |match| puts(match.inspect) }
    # split_line(line)
  end

  # Find the last element in the document
  partial = partial[0..partial.index("<DL>")-1]
  unless title == ""
    text += "==========================================================================\n"
    text += title + "\n"
    text += "==========================================================================\n"
    text += partial
    text += "\n"
    text += "\n"
  end

  # Remove <!-- --> comment tags
  text.gsub!(/<!--\/?[^>]*>/,  "")

  # Replace &nbsp; with regular spaces
  text.gsub!(/\&nbsp;/,  " ")

  puts text
end

def parse(filename)
  html = get_file_as_string(filename)

  puts html
end

# Replace athugar hvort current_text sé til, annars er öllu skipt út
# action = add_before, add_after, replace, remove

[
  { :grein => 2, :action => :replace, :new_title => "Lagaleg staða.", :new_text => "Ekkert í lögum þessum felur í sér viðurkenningu..." },
  { :grein => 2, :action => :add_after, :new_title => "Lagaleg staða.", :new_text => "Ekkert í lögum þessum felur í sér viðurkenningu..." },
  { :grein => 3, :action => :replace, :current_text => "allt að 660.000 m.kr.", :new_text => "allt að 475.000 m.kr." },
  { :grein => 4, :malsgrein => 1, :malslidur => [2,3], :action => :replace, :new_text => "Fáist síðar úr því skorið fyrir þar til bærum..." },
  { :grein => 2, :lidur => "Fjármunahreyfingar", :action => :replace, :current_text => "-270.000 m.kr.", :new_text => "-220.000 m.kr." },
  { :grein => 6, :lidur => ["6.1", "6.5", "6.6"], :action => :remove }
]


break_apart("breytingartillaga1.html")

# split_line("<!-- Tab -->&nbsp;&nbsp;&nbsp;&nbsp;<!-- Para Num 1 [1] -->1.<!-- Para Num End -->")
# split_line("<!-- WP Paired Style On: System_55 -->&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<!-- Tab -->&nbsp;&nbsp;&nbsp;&nbsp;<!-- Para Num 3 [3.0.1] -->&nbsp;&nbsp;&nbsp;&nbsp;a.<!-- Para Num End -->")
# split_line("     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c.&nbsp;&nbsp;&nbsp;&nbsp;3. mgr. fellur brott.<br>")
# split_line("<!-- Tab -->&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<!-- Tab -->&nbsp;&nbsp;&nbsp;&nbsp;<!-- Tab -->&nbsp;&nbsp;&nbsp;&nbsp;Á eftir 8. gr. laganna kemur ný grein, svohljóðandi:<br>")
