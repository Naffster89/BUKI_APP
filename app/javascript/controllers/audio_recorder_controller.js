import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-recorder"
export default class extends Controller {
  static targets = ["start", "stop", "audio", "input", "submit"]

  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
  }

  async start() {
    console.log("started");

    const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    this.mediaRecorder = new MediaRecorder(stream)
    this.audioChunks = []

    this.mediaRecorder.ondataavailable = (event) => {
      if (event.data.size > 0) this.audioChunks.push(event.data)
    }

    this.mediaRecorder.onstop = () => {
      const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' })
      const audioUrl = URL.createObjectURL(audioBlob)
      // this.audioTarget.src = audioUrl
      // this.audioTarget.load()

      const file = new File([audioBlob], 'recording.webm', { type: 'audio/webm' })
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(file)
      this.inputTarget.files = dataTransfer.files
      this.submitTarget.click()
    }

    this.mediaRecorder.start()
    this.startTarget.classList.add('d-none')
    this.stopTarget.classList.remove('d-none')
  }

  stop() {
    if (this.mediaRecorder) {
      this.mediaRecorder.stop()
    }
    this.startTarget.disabled = false
    this.stopTarget.disabled = true
  }

  play(){
    this.audioTarget.play()
  }

  playAi(event){
    console.log("🔊 Button clicked!");
    const btn = event.currentTarget;
    const text = btn.dataset.text;
    const language = btn.dataset.language;
    let ttsUrl = "/tts/speak";

    if (!text || !language) {
      console.error("Missing data-text or data-language attribute.");
      return;
    }

    if (language === "JA") {
      ttsUrl = "/tts/voicevox";
    }

    fetch(ttsUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ text: text, language: language })
    }).then(response => {
        console.log(response)
        if (!response.ok) throw new Error("TTS request failed");
        return response.blob();
      })
      .then(blob => {
        const url = URL.createObjectURL(blob);
        const audio = new Audio(url);

        // Set volume based on service
        if (language === "JA") {
          audio.volume = 0.5; // Lower volume for VoiceVox (Japanese)
        } else {
          audio.volume = 1.0; // Full volume for ElevenLabs (other languages)
        }

        audio.play();
      })
      .catch(error => {
        console.error("🎧 Error playing audio:", error);

      })
        .then(response => {
          if (!response.ok) throw new Error("TTS request failed");
          return response.blob();
        })
        .then(blob => {
          const url = URL.createObjectURL(blob);
          const audio = new Audio(url);

          // Set volume based on service
          if (language === "JA") {
            audio.volume = 0.5; // Lower volume for VoiceVox (Japanese)
          } else {
            audio.volume = 1.0; // Full volume for ElevenLabs (other languages)
          }

          audio.play();
        })
        .catch(error => {
          console.error("🎧 Error playing audio:", error);
        });

    

  }
}
