class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def show

    @book = Book.find(params[:book_id])
    @pages = @book.pages.includes(photo_attachment: :blob).order(page_number: :asc)
    @page_number = params[:page_number].to_i
    @page = @book.pages.find_by(page_number: @page_number)

    unless @page
      redirect_to book_path(@book), alert: "Page not found"
      return
    end

    @total_pages = @book.pages.count
    @languages = params[:languages] || ["EN"]

    @languages.each do |language|
      @pages.each do |page|
        page.text ||= {}
        if page.text[language].blank? && page.text["EN"].present?
          TranslateService.new(page, page.text["EN"], language).call
          page.reload
        end
        page.save
      end
    end
  end
end
