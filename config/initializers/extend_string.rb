class String
  # def to_class
  #   Kernel.const_get(self)
  # end

  def to_iso
    Iconv.conv('ISO-8859-1', 'utf-8', self)
  end

  def to_utf8
    Iconv.conv('utf-8', 'ISO-8859-1', self)
  end

  def clean_excerpt(options)
    text = self
    length = options[:max_length] ? options[:max_length] : 0

    if not text.blank? and length > 0
      pos = 0
      text = text.gsub(/<\/?[^>]*>/,  "").gsub(/\&nbsp;/,  " ").gsub("<br>", " ").gsub("</p>", " ")

      if text.length > length
        text = text[0, length]
        pos = text.rindex(' ') if options[:use_spaces]
        pos = length if pos < 1
        text = text[0, pos]

        text = "#{text}..."
      end
    end

    text
  end

end