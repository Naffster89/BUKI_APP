require "open-uri"

class BookGenerationJob < ApplicationJob
  queue_as :default

  def perform(book_id, character_name, character_species, page_count, user)
    book = Book.find(book_id)
    full_character = "#{character_name} the #{character_species}"
    title = "The Adventures of #{character_name.capitalize}"
    description = "#{character_name.capitalize}'s Lost Hat"

    style = "Studio Ghibli-inspired. Soft, watercolor-like textures with pastel tones. Whimsical and heartwarming forest setting. Gentle lighting, expressive animal characters with big eyes and subtle smiles. Traditional hand-drawn look with clean outlines. No modern digital effects, no text, and nothing surreal or abstract."

    cover_prompt = <<~PROMPT.strip
      A landscape-format illustration (1024x768) in the style of Studio Ghibli.
      Show #{full_character}, a friendly animal, searching for a hat in a forest.
      The forest should be lush and magical, with dappled sunlight and natural colors.
      The character should be clearly visible and placed in the center foreground.
      Avoid cutting off important parts near the edges.
      Do not include any text or writing in the image.
      Style: #{style}
    PROMPT

    book.update!(
      title: title,
      author: user.username,
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
      author: user.username,
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
