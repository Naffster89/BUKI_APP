import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {

    this.pageFlip = new St.PageFlip(this.containerTarget, {
      width: window.screen.width - 50,
      height: window.screen.height,
      size: "stretch",
      maxShadowOpacity: 0.5,
      showCover: false,
      mobileScrollSupport: false,

      // 🔽 THIS is what makes it single page
      useMouseEvents: true,
      flippingTime: 700,
      startPage: 0,
      disableFlipByClick: true,
      mode: "single" // ✅ SINGLE page flip mode
    });

    this.pageFlip.loadFromHTML(document.querySelectorAll(".my-page"));
    this.pageFlip.on('flip', (e) => {
      // callback code
      console.log(e.data); // current page number
    });
  }

  previous() {
    this.pageFlip.flipPrev();
  }

  next() {
    this.pageFlip.flipNext();
  }
}
