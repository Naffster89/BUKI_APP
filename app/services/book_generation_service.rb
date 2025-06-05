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
                  "text": "Once upon a time, in a peaceful forest full of tall trees and colorful flowers, lived a friendly bear named Benny. Benny loved to play and explore, always wearing his favorite hat.",
                  "image": "A happy bear named Benny, playing in a forest filled with tall trees and vibrant flowers, wearing a hat."
                },
                {
                  "page": 2,
                  "text": "One sunny day, Benny noticed that his beloved hat was missing! He looked high and low, but couldn't find it. Suddenly, a friendly blue bird fluttered down from a tree. Seeing Benny's distress, the bird offered to help him search for his hat.",
                  "image": "An upset Benny looking around in the forest. A friendly blue bird flies down to help."
                },
                {
                  "page": 3,
                  "text": "Together, Benny and the bird searched the forest. Finally, they found the hat hanging on a branch of a tall tree. Benny was so happy! The bird reminded Benny, 'It’s okay to ask for help when you're stuck.' And they continued their day, filled with new adventures.",
                  "image": "Benny and the bird finding the hat on a tree branch. They are celebrating and ready for more adventures."
                }
              ]

              Follow the same structure with your output. Do not include anything outside the JSON array.
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
      Write a 3-page children's story titled "#{@title}" by AI StoryBot.
      The main character is #{@character}.

      Follow this structure:
      - Page 1: Introduce #{@character} living happily in a peaceful forest.
      - Page 2: They realize their favorite hat is missing. A helpful blue bird appears and helps them search.
      - Page 3: Together they find the hat. End with the lesson: "It’s okay to ask for help when you're stuck."

      Guidelines:
      - Keep it light and fun for kids aged 5–7.
      - Language should be warm, simple, and easy to understand.
      - Make the blue bird friendly and encouraging.
      - Return only the JSON array, with no extra formatting.
    PROMPT
  end
end
