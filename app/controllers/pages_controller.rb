class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home

  end

  def show
   @book = Book.find(params[:book_id])
   @page = @book.pages.find_by(page_number: params[:page_number])
   raise
  end

end
