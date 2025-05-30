import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.pageFlip = new St.PageFlip(this.containerTarget, {
      width: window.screen.width,
      height: window.screen.height,
      size: "stretch",
      maxShadowOpacity: 0.5,
      showCover: false,
      mobileScrollSupport: false,

      // 🔽 THIS is what makes it single page
      useMouseEvents: true,
      flippingTime: 700,
      startPage: 0,
      disableFlipByClick: false,
      mode: "single" // ✅ SINGLE page flip mode
    });

    this.pageFlip.loadFromHTML(document.querySelectorAll(".my-page"));
  }

  previous() {
    this.pageFlip.flipPrev();
  }

  next() {
    this.pageFlip.flipNext();
  }
}
