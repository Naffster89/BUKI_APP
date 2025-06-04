class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :show]

  def home
  end

  def show
    @book = Book.find(params[:book_id])
    @pages = @book.pages.includes(photo_attachment: :blob).order(page_number: :asc)
    @page_number = params[:page_number].to_i
    @page = @pages.find_by(page_number: @page_number)

    unless @page
      redirect_to book_path(@book), alert: "Page not found"
      return
    end

    @total_pages = @book.pages.count
    @languages = (params[:languages] || ["en"]).map(&:upcase)
    TranslateBookJob.perform_later(@book, @languages, current_user)
  end
end
