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
end