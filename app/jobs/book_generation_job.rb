require "open-uri"

class BookGenerationJob < ApplicationJob
  queue_as :default

  def perform(book_id, character_name, character_species, page_count, user)
    book = Book.find(book_id)
    full_character = "#{character_name} the #{character_species}"
    title = "The Adventures of #{character_name.capitalize}"
    description = "#{character_name.capitalize}'s Lost Hat"

    style = "Beatrix Potter-inspired, pastel hand-drawn cartoon. Soft lines, friendly animal faces, consistent style. No text or surreal elements."

    cover_prompt = <<~PROMPT.strip
      A wide, soft, pastel-colored illustration of #{full_character} looking for a hat in a forest.
      The character should be centered and clearly visible in the foreground.
      Use a landscape layout (e.g., 1024x768) with a balanced composition.
      Avoid cropping important details near the edges.
      Do not include any text or writing in the image.
      Style: #{style}
    PROMPT

    # Generate structured story data from GPT (array of hashes)
    pages = BookGenerationService.new(
      title: title,
      author: "AI StoryBot",
      character: full_character,
      page_count: page_count
    ).call

    Rails.logger.info("📖 Received #{pages.size} structured pages from GPT.")

    book.update!(
      title: title,
      author: "AI StoryBot",
      description: description
    )

    # Attach cover image
    cover_url = CoverImageService.generate(prompt: cover_prompt)
    if cover_url.present?
      file = URI.open(cover_url)
      book.cover_image.attach(io: file, filename: "cover.jpg", content_type: "image/jpeg")
    else
      Rails.logger.warn "⚠️ No cover image generated for Book ID #{book.id}"
    end

    # Create pages and attach images
    pages.each do |data|
      page = book.pages.build(
        page_number: data["page"],
        text: { "EN" => data["text"] }
      )

      if page.save
        Rails.logger.info "✅ Page #{page.page_number} saved successfully."
      else
        Rails.logger.error "❌ Failed to save page #{data['page']}: #{page.errors.full_messages.join(', ')}"
        next
      end


      begin
        image_url = CoverImageService.generate(prompt: data["image"], cover_url: cover_url)
        image_file = URI.open(image_url)
        page.photo.attach(io: image_file, filename: "page_#{data['page']}.jpg", content_type: "image/jpeg")
      rescue => e
        Rails.logger.warn "⚠️ Failed to attach image for page #{data['page']}: #{e.message}"
      end
    end

    # Notify user via Turbo Stream
    Turbo::StreamsChannel.broadcast_append_to(
      "user_#{book.user_id}",
      target: "notifications",
      partial: "books/ready_notification",
      locals: { book: book }
    )

  rescue => e
    Rails.logger.error "🔥 BookGenerationJob failed for Book ID #{book_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
