class BookGenerationService
  def initialize(title:, author:, language: "EN", prompt: nil)
    @title = title
    @language = language
    @prompt = prompt || default_prompt
    @author = author
  end

  def call
    client = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])

    response = client.chat(
      parameters: {
        model: ENV.fetch("OPENAI_MODEL", "gpt-4"),
        messages: [
          { role: "system", content: "You are a children's storybook generator." },
          { role: "user", content: @prompt }
        ],
        temperature: 0.7
      }
    )

    content = response.dig("choices", 0, "message", "content")
    raise "OpenAI API did not return valid content." unless content.present?

    parse_story(content)
  end

  private

  def default_prompt
    <<~PROMPT.strip
      Write a short children's story titled "#{@title}" by #{@author}.
      Keep it simple, wholesome, and suitable for age 5–7.
      Return in plain text format, split into pages using 'Page X:' markers.
    PROMPT
  end

  def parse_story(text)
    cover_image_prompt = text[/Cover Image:\s*(.*)/i, 1]&.strip
    cleaned_story = text.gsub(/Cover Image:\s*.*$/i, "").strip
    [cleaned_story, cover_image_prompt]
  end
end
