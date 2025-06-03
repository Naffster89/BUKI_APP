class PageParserService
  def self.call(text)
    pages = []
    current = {}
    page_number = 0

    text.each_line do |line|
      line.strip!

      if line.match?(/\*\*Page (\d+):\*\*/)
        pages << current if current[:text].present?
        page_number = line[/\d+/].to_i
        current = { number: page_number }
      elsif line.start_with?("**Text:**")
        current[:text] = line.sub("**Text:**", "").strip
      elsif line.start_with?("**Image:**")
        current[:image_raw] = line.sub("**Image:**", "").strip
      end
    end

    pages << current if current[:text].present?
    pages
  end
end
