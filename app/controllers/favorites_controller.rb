class FavoritesController < ApplicationController
  def index
    @books = current_user.favorited_books
  end

  def create
    @book = Book.find(params[:book_id])
    current_user.favorite(@book)

    render turbo_stream: turbo_stream.replace(
      "favorite-#{@book.id}",
      partial: 'favorites/create', locals: {
        book: @book,
      }
    )
  end

  def destroy
     @book = Book.find(params[:id])
     current_user.unfavorite(@book)

    render turbo_stream: turbo_stream.replace(
      "favorite-#{@book.id}",
      partial: 'favorites/create', locals: {
        book: @book,
      }
    )
  end
end
