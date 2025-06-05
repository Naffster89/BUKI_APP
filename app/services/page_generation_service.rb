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
          image_url = CoverImageService.generate(prompt: data["image"], cover_url: @cover_url)
          image_file = URI.open(image_url)
          page.photo.attach(io: image_file, filename: "page_#{data['page']}.jpg", content_type: "image/jpeg")
        rescue => e
          Rails.logger.warn "⚠️ Failed to attach image for page #{data['page']}: #{e.message}"
        end
      end
    end
  end
end
