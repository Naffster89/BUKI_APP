class BooksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :new, :create]

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

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to @book, notice: "Book updated!"
    else
      render :show
    end
  end

  def new
  end

  def create
    prompt = params[:prompt]
    title = "The Adventures of #{prompt.split.first.capitalize}"
    content = "Once upon a time, #{prompt}..."
    @book = Book.new(title: title, content: content)

    if @book.save
      redirect_to @book, notice: "Your book has been created!"
    else
      flash.now[:alert] = "Something went wrong. Please try again."
      render :new
    end
  end

  private

  def book_params
    params.require(:book).permit(:language)
  end
end
