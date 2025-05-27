class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home

  end

  def show
    @book = Book.find(params[:book_id])
    @page = @book.pages.find_by(page_number: params[:page_number])

    unless @page
      redirect_to book_path(@book), alert: "Page not found"
      return
    end

    @language = params[:language] || "en"

    @page.text ||= {}

    if @page.text[@language].blank? && @page.text["en"].present?
      TranslateService.new(@page, @page.text["en"], @language).call
      @page.reload
    end

    @translated_text = @page.text[@language] || @page.text["en"]
  end
end
