class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home

  end

  def show
    @book = Book.find(params[:book_id])
    @page_number = params[:page_number].to_i
    @page = @book.pages.find_by(page_number: @page_number)
    @total_pages = @book.pages.count
    redirect_to book_page_path(@book, 1) unless @page
  end

end
