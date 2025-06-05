import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="click-sound"
export default class extends Controller {
  static targets = ['audio', 'btn']
  connect() {
    this.audioTarget.addEventListener("ended", (event) => {
      console.log('audio ended')
      this.element.submit()
    })
  }

  playSound(event) {
    event.preventDefault()
    this.audioTarget.play()
    event.currentTarget.classList.add("animate__bounce")

  }
}
