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
    @character_name = params[:character_name]
    @character_species = params[:character_species]
    @page_count = params[:page_count].to_i

    return render :new if invalid_input?

    @title = "The Adventures of #{@character_name.capitalize}"
    @book = Book.new(
      title: "Generating...",
      author: "AI StoryBot",
      description: "Generating..."
    )
    @book.user = current_user if user_signed_in?
    @book.save

    # Kick off background job
    BookGenerationJob.perform_later(@book.id, @character_name, @character_species, @page_count, current_user)

    redirect_to book_path(@book), notice: "📚 Your book is being generated! You'll be notified when it's ready."
  end

  private

  def invalid_input?
    @character_name.blank? || @character_species.blank? || !@page_count.between?(5, 10)
  end
end
