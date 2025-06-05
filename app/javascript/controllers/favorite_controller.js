import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  click() {
    // Animate the button itself
    this.element.classList.remove("clicked");
    void this.element.offsetWidth;
    this.element.classList.add("clicked");

    // Optional: reset after animation
    setTimeout(() => {
      this.element.classList.remove("clicked");
    }, 400);
  }
}
