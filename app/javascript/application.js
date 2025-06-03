console.log("JavaScript loaded!")

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

// // ElevenLabs TTS logic
// document.addEventListener("DOMContentLoaded", function () {
//   document.querySelectorAll('.tts-button').forEach(btn => {
//     btn.addEventListener('click', function (event) {
//       event.stopPropagation();
//       const language = btn.dataset.language;
//       const text = btn.dataset.text;

//       console.log("TTS clicked:", text, language); // Optional: for debugging

//       let ttsUrl = "/tts/speak";
//       if (language.toUpperCase() === "JA") {
//         ttsUrl = "/tts/voicevox";
//       }

//       fetch(ttsUrl, {
//         method: "POST",
//         headers: {
//           "Content-Type": "application/json",
//           "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
//         },
//         body: JSON.stringify({ text: text, language: language })
//       })
//       .then(response => response.blob())
//       .then(blob => {
//         const url = URL.createObjectURL(blob);
//         const audio = new Audio(url);
//         audio.play();
//       })
//       .catch(error => {
//         console.error("TTS request failed:", error);
//       });
//     });
//   });

// });
document.addEventListener("turbo:load", function () {
  console.log("✅ TTS JS loaded");
  const buttons = document.querySelectorAll(".tts-button");

  if (buttons.length === 0) {
    console.warn("No TTS buttons found.");
  }

  buttons.forEach(btn => {
    btn.addEventListener("click", () => {
      console.log("🔊 Button clicked!");

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
      })
        .then(response => {
          if (!response.ok) throw new Error("TTS request failed");
          return response.blob();
        })
        .then(blob => {
          const url = URL.createObjectURL(blob);
          const audio = new Audio(url);
          audio.play();
        })
        .catch(error => {
          console.error("🎧 Error playing audio:", error);
        });
    });
  });
});
