import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="language-select"
export default class extends Controller {
  connect() {
  }

  update(e) {
    this.element.requestSubmit()
  }
}
