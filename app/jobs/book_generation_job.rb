require 'open-uri'

class BookGenerationJob < ApplicationJob
  queue_as :default

  def perform(book_id, character_name, character_species, page_count)
    book = Book.find(book_id)
    full_character = "#{character_name} the grey #{character_species}"
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

    story_prompt = <<~PROMPT
      Write a #{page_count}-page children's story.

      Character: #{full_character}
      Theme: Looking for a hat in the forest.
      Style: #{style}

      Format each page like this:
      **Page 1:**
      **Text:** ...
      **Image:** [Brief image description. Do not include any text in the illustration.]

      Continue through to Page #{page_count}.
      Finally, include:
      Cover Image: [#{full_character} looking for a hat in a forest.]
    PROMPT

    story_text, _ = BookGenerationService.new(title:, author: "AI StoryBot", prompt: story_prompt).call

    book.update!(title:, author: "AI StoryBot", description:)

    url = CoverImageService.generate(prompt: cover_prompt)
    file = URI.open(url)
    book.cover_image.attach(io: file, filename: "cover.jpg", content_type: "image/jpeg")

    parsed_pages = PageParserService.call(story_text).first(page_count)

    parsed_pages.each_with_index do |page_data, index|
      page_number = index + 1
      image_prompt = <<~IMG.strip
        A wide illustration of #{full_character}, clearly centered and visible in the foreground.
        The scene shows: #{page_data[:text]}
        Use a landscape layout (e.g., 1024x768) with a balanced composition.
        Avoid cropping important details near the edges.
        Do not include any text, labels, or writing in the image.
        Style: #{style}
      IMG

      page = Page.create!(
        book: book,
        page_number: page_number,
        text: { "EN" => page_data[:text] },
        image_prompt: image_prompt
      )

      begin
        image_url = CoverImageService.generate(prompt: image_prompt, cover_url: book.cover_image.url)
        image_file = URI.open(image_url)
        page.photo.attach(io: image_file, filename: "page_#{page_number}.jpg", content_type: "image/jpeg")
      rescue => e
        Rails.logger.warn "Image failed for page #{page_number}: #{e.message}"
      end
    end

    Turbo::StreamsChannel.broadcast_append_to(
      "user_#{book.user_id}",
      target: "notifications",
      partial: "books/ready_notification",
      locals: { book: book }
    )
  rescue => e
    Rails.logger.error "BookGenerationJob failed for Book ID #{book_id}: #{e.message}"
  end
end
