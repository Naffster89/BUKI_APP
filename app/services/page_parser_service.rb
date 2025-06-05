class PageParserService
  def self.call(text)
    pages = []
    current = {}
    page_number = nil

    text.each_line do |line|
      line.strip!

      if line.match?(/^page\s*(\d+):/i)
        pages << current if current[:text].present?
        page_number = line[/\d+/, 0].to_i
        current = { number: page_number }

      elsif line.match?(/^text:/i)
        current[:text] = line.sub(/^text:/i, "").strip

      elsif line.match?(/^image:/i)
        current[:image_raw] = line.sub(/^image:/i, "").strip
      end
    end

    pages << current if current[:text].present?
    pages
  end
end
