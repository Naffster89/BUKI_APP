class TranslateBookJob < ApplicationJob
  queue_as :default

  def perform(book, languages)
    # Do something later
    languages.each do |language|
      book.pages.order(page_number: :asc).each do |page|
        page.text ||= {}
        if page.text[language].blank? && page.text["EN"].present?
          TranslateService.new(page, page.text["EN"], language).call
        end
      end
    end
  end
end
