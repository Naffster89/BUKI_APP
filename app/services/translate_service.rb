class TranslateService
  attr_reader :page, :text_to_translate, :language

  # def initialize(page, text_to_translate, language)
  #   @text_to_translate = text_to_translate
  # end

  # def call
  #   # use whatever you chose: chatgpt or deepl
  #   # save the translated text to the page
  #   page.text[language] = translated text
  #   page.save
  # end

  def initialize(page, text_to_translate, language)
    @page = page
    @text_to_translate = text_to_translate
    @language = language
  end

  def call
    translated = translate(text_to_translate, language)

    page.text ||= {}
    page.text[language] = translated
    page.save
  end

  private

  def translate(text, target_language)
    # DeepL requires target language codes like 'FR', 'ES', etc.
    target_lang_code = target_language.upcase # Ensure it's uppercased for DeepL

    response = DeepL.translate(
      text,
      nil,            # source language (optional)
      target_lang_code
    )

    response.text # Return the translated text
  # rescue => e
  #   Rails.logger.error("DeepL Translation Error: #{e.message}")
  #   nil
  end
end
