class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def show

    @book = Book.find(params[:book_id])
    @page_number = params[:page_number].to_i
    @page = @book.pages.find_by(page_number: @page_number)

    unless @page
      redirect_to book_path(@book), alert: "Page not found"
      return
    end

    @total_pages = @book.pages.count
    @languages = params[:languages] || ["en"]
    @page.text ||= {}

    @languages.each do |language|
      if @page.text[language].blank? && @page.text["en"].present?
        TranslateService.new(@page, @page.text["en"], language).call
        @page.reload
      end
      @translated_text = @page.text[language] || @page.text["en"]
    end
    @page.save

  end
end
