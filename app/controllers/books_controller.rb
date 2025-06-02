require 'open-uri'

class BooksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :new, :create]

  def index
    @book = Book.new
    @books = params[:query].present? ? Book.search_by_title_and_description(params[:query]) : Book.all
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
  end

  def create
    @character_name = params[:character].to_s.strip
    @character_species = params[:species].to_s.strip
    @page_count = params[:page_count].to_i

    if invalid_input?
      flash[:alert] = "Please fill out all fields and ensure page count is between 5 and 10."
      return render :new
    end

    @full_character = "#{@character_name} the #{@character_species}"
    @title = "The Adventures of #{@character_name.capitalize}"

    story_text = generate_story
    return render :new if story_text.blank?

    @book = Book.new(
      title: @title,
      author: "AI StoryBot",
      description: "#{@character_name.capitalize}'s Lost Hat"
    )

    if @book.save
      attach_cover_image
      create_story_pages(story_text)
      redirect_to @book
    else
      render :new
    end
  end

  private

  def invalid_input?
    @character_name.blank? || @character_species.blank? || !@page_count.between?(5, 10)
  end

  def style_description
    <<~STYLE.strip
      soft, pastel-colored, hand-drawn cartoon style.
      Inspired by Beatrix Potter.
      Friendly faces, rounded features, expressive eyes.
      No surrealism, sci-fi, horror, or mixed styles.
      Consistent visual style throughout. No text in the illustrations.
    STYLE
  end

  def cover_prompt
    <<~PROMPT.strip
      A soft, pastel-colored illustration of #{@full_character} looking for a hat in a forest.
      #{style_description}
    PROMPT
  end

  def story_prompt
    <<~PROMPT
      All illustrations must follow this visual style: #{style_description}

      Write a #{@page_count}-page children's story.
      Character: #{@full_character}
      Theme: Looking for a hat in the forest.

      Format each page like this:
      **Page 1:**
      **Text:** ...
      **Image:** [Brief image description in the same consistent style.]

      Continue to Page #{@page_count}.

      At the end, include:
      Cover Image: #{cover_prompt}
    PROMPT
  end

  def generate_story
    service = BookGenerationService.new(title: @title, author: "AI StoryBot", prompt: story_prompt)
    story_text, _ = service.call
    story_text
  rescue => e
    Rails.logger.error "Story generation failed: #{e.message}"
    flash[:alert] = "Story generation failed. Please try again."
    nil
  end

  def attach_cover_image
    url = CoverImageService.generate(prompt: cover_prompt)
    file = URI.open(url)
    @book.cover_image.attach(io: file, filename: "cover.jpg", content_type: "image/jpeg")
  rescue => e
    Rails.logger.warn "Cover image generation failed: #{e.message}"
  end

  def create_story_pages(story_text)
    parsed_pages = PageParserService.call(story_text)

    parsed_pages.each_with_index do |page_data, index|
      page_number = index + 1
      prompt = <<~IMG.strip
        Illustration for page #{page_number} of a story about #{@full_character}.
        Scene: #{page_data[:text]}
        #{style_description}
      IMG

      page = Page.create!(
        book: @book,
        page_number: page_number,
        text: { "EN" => page_data[:text] },
        image_prompt: prompt
      )

      begin
        url = CoverImageService.generate(prompt: prompt, cover_url: @book.cover_image.url)
        file = URI.open(url)
        page.photo.attach(io: file, filename: "page_#{page_number}.jpg", content_type: "image/jpeg")
      rescue => e
        Rails.logger.warn "Image generation failed for page #{page_number}: #{e.message}"
      end
    end
  end
end
