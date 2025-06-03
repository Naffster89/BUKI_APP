# app/services/eleven_labs_tts_service.rb
require 'net/http'
require 'uri'
require 'json'

class ElevenLabsTtsService
  BASE_URL = "https://api.elevenlabs.io/v1"

  def self.generate_speech(attr = {})
    uri = URI("#{BASE_URL}/text-to-speech/#{attr[:voice_id]}")

    request = Net::HTTP::Post.new(uri)
    request["content-type"] = "application/json"
    request["xi-api-key"] = ENV["ELEVENLABS"]
    request.body = {
      text: attr[:text],
      model_id: "eleven_multilingual_v2", # Use multilingual for multilingual support
      voice_settings: {
        stability: 0.5,
        similarity_boost: 0.75
      }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      filename = Rails.root.join("tmp", "output_#{Time.now.to_i}.mp3")
      File.open(filename, "wb") { |f| f.write(response.body) }
      return filename.to_s
    else
      Rails.logger.error("TTS error: #{response.code} - #{response.body}")
      nil
    end
  end
end
