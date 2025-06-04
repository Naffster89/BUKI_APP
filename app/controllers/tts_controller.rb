class TtsController < ApplicationController
  protect_from_forgery with: :null_session

  def speak
    text = params[:text]
    language = params[:language] || "EN"

    voice_id = select_voice_id(language)
    audio_path = ElevenLabsTtsService.generate_speech(text: text, voice_id: voice_id, api_key: ENV["ELEVENLABS_API_KEY"])

    if audio_path
      send_file audio_path, type: "audio/mpeg", disposition: "inline"
    else
      render json: { error: "TTS request failed" }, status: :unprocessable_entity
    end
  end

  def voicevox
    text = params[:text]

    speaker = "VOICEVOX:波音リツ（ノーマル）"
    service = VoiceVoxService.new(ENV["VOICEVOX_API_KEY"])

    audio_file_path = service.synthesize(text, speaker)
    if audio_file_path
      send_file audio_file_path, type: "audio/wav", disposition: "inline"
    else
      render json: { error: "TTS request failed" }, status: :unprocessable_entity
    end
  end

  private

  def select_voice_id(language)
    # Map your supported languages to ElevenLabs voice IDs
    {
      "en" => "cVd39cx0VtXNC13y5Y7z",
      "es" => "tXgbXPnsMpKXkuTgvE3h",
    }[language] || "cVd39cx0VtXNC13y5Y7z"
  end

end
