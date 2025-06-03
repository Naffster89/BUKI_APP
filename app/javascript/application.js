// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

document.addEventListener("turbo:load", () => {
  setTimeout(() => {
    document.querySelectorAll("#notifications .alert").forEach((el) => {
      el.classList.add("fade");
      setTimeout(() => el.remove(), 500);
    });
  }, 5000); // Wait 5 seconds before fading
});
