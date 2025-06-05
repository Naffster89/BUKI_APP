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
              You are a children’s story generator. Output must be valid JSON only — no extra commentary, markdown, or explanations.

              Format your output as a JSON array of exactly 3 hashes, each with the keys: "page", "text", and "image".

              Example:
              [
                {
                  "page": 1,
                  "text": "Benny the bear loved his red hat. He wore it every day in the forest.",
                  "image": "A happy bear wearing a red hat, walking through a green forest."
                },
                {
                  "page": 2,
                  "text": "One day, the hat was gone! A blue bird flew down. 'Let’s find it!' she chirped.",
                  "image": "Benny looking sad without his hat, as a blue bird flutters beside him."
                },
                {
                  "page": 3,
                  "text": "They found the hat on a branch. Benny smiled. 'Thanks!' he said. 'Friends help!'",
                  "image": "Benny smiling with his hat back on, the blue bird next to him under a tree."
                }
              ]

              Follow the same structure with your output. Do not include anything outside the JSON array.
            SYS
          },
          {
            role: "user",
            content: @prompt
          }
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
      Write a 3-page children's story titled "#{@title}" by AI StoryBot.
      The main character is #{@character}.

      Follow this structure:
      - Page 1: Introduce #{@character} living happily in a peaceful forest.
      - Page 2: They realize their favorite hat is missing. A helpful blue bird appears and helps them search.
      - Page 3: Together they find the hat. End with the lesson: "It’s okay to ask for help when you're stuck."

      Guidelines:
      - Keep each page to 1–2 very short sentences.
      - Target children aged 3–5.
      - Use simple, cheerful language.
      - The blue bird should be friendly and encouraging.
      - Return only the JSON array with no extra formatting.
    PROMPT
  end
end
