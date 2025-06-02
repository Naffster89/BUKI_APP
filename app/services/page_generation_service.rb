class PageGenerationService
  def initialize(story_text, book, cover_url = nil)
    @story_text = story_text
    @book = book
    @cover_url = cover_url
  end

  def call
    pages = extract_pages(@story_text)

    pages.each do |page|
      text = page[:text].strip
      image_prompt = build_image_prompt(page[:number], text, page[:image_raw])

      page_record = @book.pages.create!(
        page_number: page[:number],
        text: { "EN" => text },
        image_prompt: image_prompt
      )

      next unless image_prompt.present?

      begin
        image_url = CoverImageService.generate(prompt: image_prompt, cover_url: @cover_url)
        image_file = URI.open(image_url)
        page_record.photo.attach(io: image_file, filename: "page_#{page[:number]}.jpg", content_type: "image/jpeg")
      rescue => e
        Rails.logger.warn "Image generation failed for page #{page[:number]}: #{e.message}"
        Rails.logger.warn "Prompt was: #{image_prompt}"
      end
    end
  end

  private

  def extract_pages(story_text)
    story_text.scan(/\*\*Page (\d+):\*\*\s*\*\*Text:\*\*\s*(.*?)\s*\*\*Image:\*\*\s*\[(.*?)\]/m).map do |number, text, image|
      { number: number.to_i, text: text, image_raw: image }
    end
  end

  def build_image_prompt(page_number, page_text, image_description)
    <<~PROMPT.strip
      Page #{page_number} illustration.

      Style:
      Soft, pastel-colored, hand-drawn cartoon. Inspired by Beatrix Potter and early Disney books.
      Rounded features, expressive faces, consistent character design from cover.
      No surrealism, sci-fi, horror, or mixed styles.

      Character:
      Same character as on the cover. Do not add new characters. Maintain look and outfit.

      Scene:
      #{image_description.presence || page_text}
    PROMPT
  end
end
