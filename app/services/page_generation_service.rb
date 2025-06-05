require "open-uri"

class PageGenerationService
  def initialize(pages_data, book, cover_url = nil)
    @pages_data = pages_data
    @book = book
    @cover_url = cover_url
  end

  def call
    @pages_data.each do |data|
      page = @book.pages.build(
        page_number: data["page"],
        text: { "EN" => data["text"] }
      )

      if page.save
        Rails.logger.info "✅ Page #{page.page_number} saved successfully."
      else
        Rails.logger.error "❌ Failed to save page #{data['page']}: #{page.errors.full_messages.join(', ')}"
        next
      end

      if data["image"].present?
        begin
          styled_prompt = build_styled_prompt(data["page"], data["image"])
          image_url = CoverImageService.generate(prompt: styled_prompt, cover_url: @cover_url)
          image_file = URI.open(image_url)
          page.photo.attach(io: image_file, filename: "page_#{data['page']}.jpg", content_type: "image/jpeg")
        rescue => e
          Rails.logger.warn "⚠️ Failed to attach image for page #{data['page']}: #{e.message}"
        end
      end
    end
  end

  private

  def build_styled_prompt(page_number, raw_description)
    <<~PROMPT.strip
      Illustration for page #{page_number} of a children's book.
      Scene: #{raw_description}
      Style: Beatrix Potter-inspired, pastel hand-drawn cartoon.
      Requirements:
      - Soft lines and gentle colors
      - Friendly animal characters
      - Consistent art style with other pages
      - Landscape layout (1024x768)
      - No text, writing, or speech bubbles
      - Characters must be fully visible (no cropping at edges)
    PROMPT
  end
end
