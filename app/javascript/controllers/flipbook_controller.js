import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", 'form']

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
      startPage: Number(this.element.dataset.page),
      disableFlipByClick: true,
      mode: "single" // ✅ SINGLE page flip mode
    });

    this.pageFlip.loadFromHTML(document.querySelectorAll(".my-page"));
    this.pageFlip.on('flip', (e) => {
      // callback code
      const bookId = Number(this.element.dataset.book)
      // console.log(e.data); // current page number
      this.formTarget.action = `/books/${bookId}/pages/${e.data}`
      window.history.pushState(`page${e.data}`, 'Buki', `/books/${bookId}/pages/${e.data}`);

      // console.log(this.formTarget)
    });
  }

  previous() {
    this.pageFlip.flipPrev();
  }

  next() {
    this.pageFlip.flipNext();
  }
}
