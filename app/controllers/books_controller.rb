class BooksController < ApplicationController
    skip_before_action :authenticate_user!, only: [ :index, :show ]
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
end
