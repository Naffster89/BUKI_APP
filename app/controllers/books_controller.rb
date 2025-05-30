class BooksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :new, :create]

  def index
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

    @book = Book.new

    if page_count < 5
      render :new
      return
    end

    prompt = <<~PROMPT
      I want a children's story with the following:
      - Main character: #{character}
      - Action: #{action}
      - Location: #{location}
      - Total pages: #{page_count}

      Please write:
      1. A short story split into #{page_count} parts (one per page).
      2. For each part, include a brief image description.

      Format:
      Page 1:
      Text: ...
      Image: ...
    PROMPT
    client = OpenAI::Client.new
    response = client.chat(parameters: {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Tell me why Ruby is an elegant coding language"}]
    })
    # client = OpenAI::Client.new
    # response = client.chat(
    #   parameters: {
    #     model: "gpt-4.1",
    #     messages: [
    #       { role: "system", content: "You are a creative children's book author." },
    #       { role: "user", content: prompt }
    #     ],
    #     temperature: 0.9,
    #     max_tokens: 1500
    #   }
    # )


    result = response["choices"].first["text"]
    title = "The Adventures of #{character.capitalize}"
    @book = Book.new(title: title, description: result, author: "AI StoryBot")

    if @book.save
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
