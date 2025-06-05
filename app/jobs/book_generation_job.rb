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

    book.update!(
      title: title,
      author: "AI StoryBot",
      description: description
    )

    # ✅ Broadcast after metadata update
    Turbo::StreamsChannel.broadcast_replace_to(
      "book_#{book.id}",
      partial: "books/container",
      target: "book-#{book.id}",
      locals: { book: book, current_user: user }
    )

    # Attach cover image
    cover_url = CoverImageService.generate(prompt: cover_prompt)
    if cover_url.present?
      file = URI.open(cover_url)
      book.cover_image.attach(io: file, filename: "cover.jpg", content_type: "image/jpeg")

      # ✅ Broadcast again after attaching cover
      Turbo::StreamsChannel.broadcast_replace_to(
        "book_#{book.id}",
        partial: "books/container",
        target: "book-#{book.id}",
        locals: { book: book, current_user: user }
      )
    else
      Rails.logger.warn "⚠️ No cover image generated for Book ID #{book.id}"
    end

    # Generate structured story data from GPT (array of hashes)
    pages = BookGenerationService.new(
      title: title,
      author: "AI StoryBot",
      character: full_character,
      page_count: page_count
    ).call

    Rails.logger.info("📖 Received #{pages.size} structured pages from GPT.")

   # Generate pages and attach images
    PageGenerationService.new(pages, book, cover_url).call

    Turbo::StreamsChannel.broadcast_replace_to(
      "book_#{book.id}",
      partial: "books/container",
      target: "book-#{book.id}",
      locals: { book: book, current_user: user }
    )

    p pages
    p book

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
