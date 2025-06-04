require 'open-uri'
require 'uri'
require 'json'
require 'net/http'

class VoiceVoxService
  def initialize(apiKey)
    # get your apikey here: https://su-shiki.com/api/
    @apiKey = apiKey
    @speakers = [
    	"VOICEVOX:四国めたん（あまあま）",
    	"VOICEVOX:ずんだもん（あまあま）",
    	"VOICEVOX:四国めたん（ノーマル）",
    	"VOICEVOX:ずんだもん（ノーマル）",
    	"VOICEVOX:四国めたん（セクシー）",
    	"VOICEVOX:ずんだもん（セクシー）",
    	"VOICEVOX:四国めたん（ツンツン）",
    	"VOICEVOX:ずんだもん（ツンツン）",
    	"VOICEVOX:春日部つむぎ（ノーマル）",
    	"VOICEVOX:波音リツ（ノーマル）",
      "VOICEVOX:雨晴はう（ノーマル）",
      "VOICEVOX:玄野武宏（ノーマル）",
      "VOICEVOX:白上虎太郎（ふつう）",
      "VOICEVOX:青山龍星（ノーマル）",
      "VOICEVOX:冥鳴ひまり（ノーマル）",
      "VOICEVOX:九州そら（あまあま）",
      "VOICEVOX:九州そら（ノーマル）",
      "VOICEVOX:九州そら（セクシー）",
      "VOICEVOX:九州そら（ツンツン）",
      "VOICEVOX:九州そら（ささやき）",
      "VOICEVOX:もち子(cv 明日葉よもぎ)（ノーマル）",
      "VOICEVOX:剣崎雌雄（ノーマル）",
      "VOICEVOX:ずんだもん（ささやき）",
      "VOICEVOX:WhiteCUL（ノーマル）",
      "VOICEVOX:WhiteCUL（たのしい）",
      "VOICEVOX:WhiteCUL（かなしい）",
      "VOICEVOX:WhiteCUL（びえーん）",
      "VOICEVOX:後鬼（人間ver.）",
      "VOICEVOX:後鬼（ぬいぐるみver.）",
      "VOICEVOX:No.7（ノーマル）",
      "VOICEVOX:No.7（アナウンス）",
      "VOICEVOX:No.7（読み聞かせ）",
      "VOICEVOX:白上虎太郎（わーい）",
      "VOICEVOX:白上虎太郎（びくびく）",
      "VOICEVOX:白上虎太郎（おこ）",
      "VOICEVOX:白上虎太郎（びえーん）",
      "VOICEVOX:四国めたん（ささやき）",
      "VOICEVOX:四国めたん（ヒソヒソ）",
      "VOICEVOX:ずんだもん（ヒソヒソ）",
      "VOICEVOX:玄野武宏（喜び）",
      "VOICEVOX:玄野武宏（ツンギレ）",
      "VOICEVOX:玄野武宏（悲しみ）",
      "VOICEVOX:ちび式じい（ノーマル）",
      "VOICEVOX:櫻歌ミコ（ノーマル）",
      "VOICEVOX:櫻歌ミコ（第二形態）",
      "VOICEVOX:櫻歌ミコ（ロリ）",
      "VOICEVOX:小夜/SAYO（ノーマル）",
      "VOICEVOX:ナースロボ＿タイプＴ（ノーマル）",
      "VOICEVOX:ナースロボ＿タイプＴ（楽々）",
      "VOICEVOX:ナースロボ＿タイプＴ（恐怖）",
      "VOICEVOX:ナースロボ＿タイプＴ（内緒話）",
      "VOICEVOX:†聖騎士 紅桜†（ノーマル）",
      "VOICEVOX:雀松朱司（ノーマル）",
      "VOICEVOX:麒ヶ島宗麟（ノーマル）",
      "VOICEVOX:春歌ナナ（ノーマル）",
      "VOICEVOX:猫使アル（ノーマル）",
      "VOICEVOX:猫使アル（おちつき）",
      "VOICEVOX:猫使アル（うきうき）",
      "VOICEVOX:猫使ビィ（ノーマル）",
      "VOICEVOX:猫使ビィ（おちつき）",
      "VOICEVOX:猫使ビィ（人見知り）",
      "VOICEVOX:中国うさぎ（ノーマル）",
      "VOICEVOX:中国うさぎ（おどろき）",
      "VOICEVOX:中国うさぎ（こわがり）",
      "VOICEVOX:中国うさぎ（へろへろ）",
      "VOICEVOX:波音リツ（クイーン）",
      "VOICEVOX:もち子(cv 明日葉よもぎ)（セクシー／あん子）",
      "VOICEVOX:栗田まろん（ノーマル）",
      "VOICEVOX:あいえるたん（ノーマル）",
      "VOICEVOX:満別花丸（ノーマル）",
      "VOICEVOX:満別花丸（元気）",
      "VOICEVOX:満別花丸（ささやき）",
      "VOICEVOX:満別花丸（ぶりっ子）",
      "VOICEVOX:満別花丸（ボーイ）",
      "VOICEVOX:琴詠ニア（ノーマル）",
      "VOICEVOX:ずんだもん（ヘロヘロ）",
      "VOICEVOX:ずんだもん（なみだめ）",
      "VOICEVOX:もち子(cv 明日葉よもぎ)（泣き）",
      "VOICEVOX:もち子(cv 明日葉よもぎ)（怒り）",
      "VOICEVOX:もち子(cv 明日葉よもぎ)（喜び）",
      "VOICEVOX:もち子(cv 明日葉よもぎ)（のんびり）",
      "VOICEVOX:青山龍星（熱血）",
      "VOICEVOX:青山龍星（不機嫌）",
      "VOICEVOX:青山龍星（喜び）",
      "VOICEVOX:青山龍星（しっとり）",
      "VOICEVOX:青山龍星（かなしみ）",
      "VOICEVOX:青山龍星（囁き）",
      "VOICEVOX:後鬼（人間（怒り）ver.）",
      "VOICEVOX:後鬼（鬼ver.）"
    ]
  end

  def speakers
    # getting speakers
    speaker_endpoint = "https://api.tts.quest/v3/voicevox/speakers_array?key=#{@apiKey}"
    speakers_serialized = URI.parse(speaker_endpoint).read
    speakers = JSON.parse(speakers_serialized)
    speakers
  end

  def synthesize(text, speaker)
    text = URI.encode_www_form_component(text)
    speaker_id = @speakers.index(speaker) || 0
    # speaker = URI.encode_www_form_component(speaker)
    # for testing
    # text = URI.encode_www_form_component("風の子フーは、くまのストーブ店でガラスのストーブを手にいれました。美しいストーブに火をつけて暖まっていますと、ひめねずみがやってきました。時間と空間をこえて、安房直子の不思議な世界が広がります。")
    # speaker = URI.encode_www_form_component("VOICEVOX:四国めたん（あまあま）")

    synthesize_endpoint = "https://api.tts.quest/v3/voicevox/synthesis?speaker=#{speaker_id}&text=#{text}&key=#{@apiKey}"

    tts_serialized = URI.parse(synthesize_endpoint).read
    tts = JSON.parse(tts_serialized)

    # This is how tts will look like
    # tts = {"success"=>true,
    #     "isApiKeyValid"=>false,
    #     "speakerName"=>"VOICEVOX:波音リツ（ノーマル）",
    #     "audioStatusUrl"=>"https://audio2.tts.quest/v1/data/82c09ad4d32c3c63de24124aaf15f37dc43e9263cca50777d9ece1aaeb9ecb7c/status.json",
    #     "wavDownloadUrl"=>"https://audio2.tts.quest/v1/data/82c09ad4d32c3c63de24124aaf15f37dc43e9263cca50777d9ece1aaeb9ecb7c/audio.wav",
    #     "mp3DownloadUrl"=>"https://audio2.tts.quest/v1/data/82c09ad4d32c3c63de24124aaf15f37dc43e9263cca50777d9ece1aaeb9ecb7c/audio.mp3",
    #     "mp3StreamingUrl"=>"https://audio2.tts.quest/v1/data/82c09ad4d32c3c63de24124aaf15f37dc43e9263cca50777d9ece1aaeb9ecb7c/audio.mp3s"
    #   }
    return nil unless tts["success"] && tts["mp3DownloadUrl"]

    audio_url = tts["mp3DownloadUrl"]
    file_path = Rails.root.join("tmp", "voicevox_#{SecureRandom.hex(8)}.mp3")

    URI.open(audio_url) do |audio|
      File.open(file_path, "wb") { |f| f.write(audio.read) }
    end

    file_path.to_s
  end
end
