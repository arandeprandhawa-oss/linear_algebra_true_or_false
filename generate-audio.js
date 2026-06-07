const fs = require("fs");
const path = require("path");
const textToSpeech = require("@google-cloud/text-to-speech");

const client = new textToSpeech.TextToSpeechClient();

const ETAPE_FILES = [
  "etapes/etape1.js",
  "etapes/etape2.js",
  "etapes/etape3.js",
  "etapes/etape4.js"
];

const AUDIO_DIR = "audio";
const MANIFEST_FILE = "audio-manifest.json";

if (!fs.existsSync(AUDIO_DIR)) {
  fs.mkdirSync(AUDIO_DIR);
}

function slugify(text) {
  return String(text)
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/œ/g, "oe")
    .replace(/æ/g, "ae")
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .slice(0, 80);
}

function loadEtapeData(filePath) {
  const raw = fs.readFileSync(filePath, "utf8");

  const window = {};
  eval(raw);

  if (!window.ETAPE_DATA || !Array.isArray(window.ETAPE_DATA.vocab)) {
    throw new Error(`Could not find window.ETAPE_DATA.vocab in ${filePath}`);
  }

  return window.ETAPE_DATA.vocab;
}

async function makeAudio(text, outputPath) {
  const request = {
    input: { text },
    voice: {
      languageCode: "fr-CA",
      name: "fr-CA-Neural2-A"
    },
    audioConfig: {
      audioEncoding: "MP3",
      speakingRate: 0.86
    }
  };

  const [response] = await client.synthesizeSpeech(request);
  fs.writeFileSync(outputPath, response.audioContent, "binary");
}

async function main() {
  const manifest = {};

  for (const etapeFile of ETAPE_FILES) {
    if (!fs.existsSync(etapeFile)) {
      console.log(`Skipping missing file: ${etapeFile}`);
      continue;
    }

    console.log(`Reading ${etapeFile}`);

    const vocab = loadEtapeData(etapeFile);

    for (const card of vocab) {
      if (!card.fr) continue;

      const frenchText = card.fr.trim();
      const filename = `${slugify(frenchText)}.mp3`;
      const outputPath = path.join(AUDIO_DIR, filename);

      manifest[frenchText] = `audio/${filename}`;

      if (fs.existsSync(outputPath)) {
        console.log(`Already exists: ${filename}`);
        continue;
      }

      console.log(`Generating: ${frenchText}`);

      try {
        await makeAudio(frenchText, outputPath);
      } catch (err) {
        console.error(`Failed for: ${frenchText}`);
        console.error(err.message);
      }
    }
  }

  fs.writeFileSync(MANIFEST_FILE, JSON.stringify(manifest, null, 2), "utf8");
  console.log(`Done. Created ${MANIFEST_FILE}`);
}

main();