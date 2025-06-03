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

    @book = Book.new(title: "Generating...", author: "AI StoryBot", description: "Generating...")
    @book.user = current_user if user_signed_in?
    @book.save!

    BookGenerationJob.perform_later(@book.id, @character_name, @character_species, @page_count)

    redirect_to books_path, notice: "📚 Your book is being generated! You'll be notified when it's ready."
  end

  private

  def invalid_input?
    @character_name.blank? || @character_species.blank? || !@page_count.between?(5, 10)
  end
end
