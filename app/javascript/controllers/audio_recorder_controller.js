import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-recorder"
export default class extends Controller {
  static targets = ["start", "stop", "audio", "input", "delete", "submit"]

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
}
