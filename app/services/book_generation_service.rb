require 'json'

class BookGenerationService
  def initialize(title:, author:, character:, page_count:)
    @title = title
    @character = character
    @page_count = page_count
    @prompt = build_prompt
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  def call
    response = @client.chat(
      parameters: {
        model: ENV.fetch("OPENAI_MODEL", "gpt-4"),
        messages: [
          {
            role: "system",
            content: <<~SYS
              You are a children's story generator that must return strict JSON.
              Do not include explanations, markdown, or any extra content.
              Output only a JSON array of 5 hashes with the keys: "page", "text", and "image".

              Each page must follow this exact plot structure and return ONLY valid JSON in this format:

              [
                { "page": 1, "text": "Page 1 story text...", "image": "Image description for page 1" },
                { "page": 2, "text": "Page 2 story text...", "image": "Image description for page 2" },
                { "page": 3, "text": "Page 3 story text...", "image": "Image description for page 3" },
                { "page": 4, "text": "Page 4 story text...", "image": "Image description for page 4" },
                { "page": 5, "text": "Page 5 story text...", "image": "Image description for page 5" }
              ]

              Follow this plot outline exactly:
              Page 1: Introduce #{@character} and the peaceful forest they live in.
              Page 2: Introduce their problem — they’ve lost their favorite hat.
              Page 3: They search high and low and get help from a friend.
              Page 4: They nearly give up, but find a clue.
              Page 5: They find the hat and learn a lesson about asking for help.

              Each hash must represent one story page.
            SYS
          },
          { role: "user", content: @prompt }
        ],
        temperature: 0.7
      }
    )

    content = response.dig("choices", 0, "message", "content")
    raise "OpenAI API did not return valid content." unless content.present?

    puts "--- RAW OPENAI OUTPUT START ---"
    puts content
    puts "--- RAW OPENAI OUTPUT END ---"

    JSON.parse(content)
  rescue JSON::ParserError => e
    raise "❌ JSON parsing failed: #{e.message}\nRaw content: #{content}"
  end

  private

  def build_prompt
    <<~PROMPT
      Write a 5-page children's story titled "#{@title}" by AI StoryBot.
      The main character is #{@character}.
      Each page must follow this exact plot structure and return ONLY valid JSON in this format:

      [
        { "page": 1, "text": "Page 1 story text...", "image": "Image description for page 1" },
        { "page": 2, "text": "Page 2 story text...", "image": "Image description for page 2" },
        { "page": 3, "text": "Page 3 story text...", "image": "Image description for page 3" },
        { "page": 4, "text": "Page 4 story text...", "image": "Image description for page 4" },
        { "page": 5, "text": "Page 5 story text...", "image": "Image description for page 5" }
      ]

      Follow this plot outline exactly:
      Page 1: Introduce #{@character} and the peaceful forest they live in.
      Page 2: Introduce their problem — they’ve lost their favorite hat.
      Page 3: They search high and low and get help from a friend.
      Page 4: They nearly give up, but find a clue.
      Page 5: They find the hat and learn a lesson about asking for help.

      Notes:
      - Language should be simple and engaging for children aged 5–7.
      - Do not include any non-JSON output.
    PROMPT
  end
end
