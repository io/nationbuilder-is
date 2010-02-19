def line_is_a_new_element(line)
  result = ""
  line.scan(/<!-- Para Num \d \[\d\] -->(.*?)(<!-- Para Num End -->)/) { |match| result = match[0] }
  result.empty? ? false : result
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
    # line = split_line(line)
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
  end

  # Find the last element in the document
  unless partial.empty?
    partial = partial[0..partial.index("<DL>")-1]
    unless title == ""
      text += "==========================================================================\n"
      text += title + "\n"
      text += "==========================================================================\n"
      text += partial
      text += "\n"
      text += "\n"
    end
  end

  # Remove HTML tags
  text.gsub!(/<\/?[^>]*>/,  "")

  # Replace &nbsp; with regular spaces
  text.gsub!(/\&nbsp;/,  " ")

  # Trim
  text.strip!

  puts text
end

def parse(filename)
  html = get_file_as_string(filename)

  puts html
end

break_apart("breytingartillaga3.html")

