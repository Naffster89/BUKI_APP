class BooksController < ApplicationController
  def index
    @books = Book.new
  end

  def show
  end
end
