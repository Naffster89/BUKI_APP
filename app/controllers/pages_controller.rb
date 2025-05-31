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
    @languages = (params[:languages] || ["en"]).compact
    @page.text ||= {}

    @translated_text = nil
    @languages.each do |lang|
      if @page.text[lang].present?
        @translated_text = @page.text[lang]
        break
      elsif @page.text["en"].present?
        TranslateService.new(@page, @page.text["en"], lang).call
        @page.reload
        @translated_text = @page.text[lang]
        break
      end
    end

    @translated_text ||= @page.text["en"] || "No content available."
  end
end
