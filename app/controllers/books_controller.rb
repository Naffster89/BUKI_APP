require 'open-uri'

class BooksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :new, :create]

  def index
    @book = Book.new

    if params[:query].present?
      @books = Book.search_by_title_and_description(params[:query])
    else
      @books = Book.all
    end
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
  end

  def create
    character = params[:character]
    action = params[:action]
    location = params[:location]
    page_count = params[:page_count].to_i

    if page_count < 5
      render :new
      return
    end

    prompt = <<~PROMPT
      Write a #{page_count}-page children's story.

      Story elements:
      - Main character: #{character}
      - Action: #{action}
      - Location: #{location}

      Format each page exactly like this:

      **Page 1:**
      **Text:** ...
      **Image:** ...

      Continue to Page #{page_count}.

      At the end, include this line:
      Cover Image: [one-line description of the front cover]

      Do not include any title or explanations, only content.
    PROMPT

    story_text, image_prompt = BookGenerationService.new(prompt).generate_story_and_cover_prompt
    image_url = image_prompt.present? ? CoverImageService.generate(image_prompt) : nil
    cover_file = image_url.present? ? URI.open(image_url) : nil

    @book = Book.new(
      title: "The Adventures of #{character.capitalize}",
      author: "AI StoryBot",
      description: ""
    )

    @book.cover_image.attach(io: cover_file, filename: "cover.jpg", content_type: "image/jpeg") if cover_file

    if @book.save
      pages = story_text.scan(/\*\*Page (\d+):\*\*.*?\*\*Text:\*\*(.*?)\*\*Image:\*\*(.*?)(?=(\*\*Page|\z))/m)

      pages.each do |page_number, text, image_prompt, _|
        page = @book.pages.create!(
          page_number: page_number.to_i,
          text: { "en" => text.strip },
          image_prompt: image_prompt.strip
        )

        if image_prompt.present?
          begin
            generated_url = CoverImageService.generate(image_prompt)
            image_file = URI.open(generated_url)
            page.photo.attach(io: image_file, filename: "page_#{page_number}.jpg", content_type: "image/jpeg")
          rescue => e
            Rails.logger.warn "Image generation failed for page #{page_number}: #{e.message}"
          end
        end
      end

      redirect_to @book
    else
      render :new
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to @book
    else
      render :show
    end
  end

  private

  def book_params
    params.require(:book).permit(:language)
  end
end
