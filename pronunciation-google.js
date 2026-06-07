(function () {
  "use strict";

  let audioManifest = {};
  let manifestLoaded = false;
  let currentAudio = null;

  function cleanText(text) {
    return String(text || "")
      .replace(/\s+/g, " ")
      .trim();
  }

  async function loadAudioManifest() {
    try {
      const response = await fetch("audio-manifest.json");

      if (!response.ok) {
        throw new Error("audio-manifest.json could not be loaded.");
      }

      audioManifest = await response.json();
      manifestLoaded = true;
      console.log("French audio manifest loaded.");
    } catch (error) {
      console.warn("Pronunciation audio not loaded:", error.message);
    }
  }

  function playFrenchAudio(text) {
    const phrase = cleanText(text);

    if (!phrase) return;

    if (!manifestLoaded) {
      console.warn("Audio manifest is still loading.");
      return;
    }

    const audioPath = audioManifest[phrase];

    if (!audioPath) {
      console.warn("No audio found for:", phrase);
      return;
    }

    if (currentAudio) {
      currentAudio.pause();
      currentAudio.currentTime = 0;
    }

    currentAudio = new Audio(audioPath);

    currentAudio.play().catch(error => {
      console.warn("Could not play audio:", error.message);
    });
  }

  function makePronounceButton(text) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "pronounce-btn";
    button.textContent = "🔊";
    button.title = "Pronounce";
    button.setAttribute("aria-label", "Pronounce French");

    button.addEventListener("click", function (event) {
      event.preventDefault();
      event.stopPropagation();
      playFrenchAudio(text);
    });

    return button;
  }

  function addButtonToElement(element, text) {
    if (!element) return;
    if (element.dataset.pronounceAdded === "true") return;

    const phrase = cleanText(text);
    if (!phrase) return;

    element.dataset.pronounceAdded = "true";
    element.appendChild(document.createTextNode(" "));
    element.appendChild(makePronounceButton(phrase));
  }

  function autoAttachPronunciationButtons() {
    const selectors = [
      ".answer",
      ".fr",
      ".french",
      ".card-answer",
      ".revealed",
      "#answer",
      "#fr",
      "#frenchAnswer",
      "[data-fr]"
    ];

    selectors.forEach(selector => {
      document.querySelectorAll(selector).forEach(element => {
        const phrase = element.dataset.fr || element.textContent;
        addButtonToElement(element, phrase);
      });
    });
  }

  window.playFrenchAudio = playFrenchAudio;

  window.addFrenchAudioButton = function (element, frenchText) {
    addButtonToElement(element, frenchText);
  };

  document.addEventListener("DOMContentLoaded", async function () {
    await loadAudioManifest();
    autoAttachPronunciationButtons();

    const observer = new MutationObserver(function () {
      autoAttachPronunciationButtons();
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  });

  const style = document.createElement("style");
  style.textContent = `
    .pronounce-btn {
      margin-left: 8px;
      padding: 4px 8px;
      border-radius: 999px;
      border: 1px solid rgba(0, 0, 0, 0.25);
      background: white;
      cursor: pointer;
      font-size: 1rem;
      line-height: 1;
    }

    .pronounce-btn:hover {
      filter: brightness(0.94);
    }
  `;

  document.head.appendChild(style);
})();