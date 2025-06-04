class CoverImageService
  def self.generate(prompt:, cover_url: nil)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    style_reference = if cover_url.present?
      "\nMatch the visual style of this image: #{cover_url}"
    else
      ""
    end

    final_prompt = "#{prompt}#{style_reference}"

    response = client.images.generate(
      parameters: {
        prompt: final_prompt.strip,
        size: "512x512",
        n: 1
      }
    )

    response.dig("data", 0, "url")
  rescue => e
    Rails.logger.error("Cover image generation failed: #{e.message}")
    nil
  end
end
