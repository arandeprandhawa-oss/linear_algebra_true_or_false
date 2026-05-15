# French Flashcards · Étape platform

https://arandeprandhawa-oss.github.io/french-quiz/  

A small multi-étape flashcards app. Two modes per étape: **1v1 multiplayer** (Firestore-backed)
and **solo** (local spaced-repetition). The architecture is built so adding Étape 3, 4, … later
is a copy-paste-and-config job, not a code rewrite.

## File map

```
index.html        ← Étape 2 (default landing) · 1v1 lobby
etape1.html       ← Étape 1 · 1v1 lobby
solo.html         ← Étape 2 · Solo
solo1.html        ← Étape 1 · Solo
firestore.rules   ← Firestore security rules (must be deployed)
etapes/
  registry.js     ← single source of truth for which étapes exist
  etape1.js       ← Étape 1 vocab + category labels (230 entries)
  etape2.js       ← Étape 2 vocab + category labels (516 entries)
```

The four HTML files are **shells** — they don't contain vocab data. Each one loads:

1. `etapes/registry.js` (the list of all étapes)
2. `etapes/etape{N}.js` (the active étape's vocab + categoryLabels)
3. Its own game logic (which reads `window.ETAPE_DATA.vocab` and
   `window.ETAPE_DATA.categoryLabels`)

The tab bar at the top of every page is generated dynamically from the registry,
so it always reflects which étapes are configured.

## How to add a new étape (e.g. Étape 3)

This is the workflow you should expect. It takes about 5 minutes once the vocab is ready.

### 1. Create `etapes/etape3.js`

Copy the shape of `etape1.js` or `etape2.js`:

```js
window.ETAPE_DATA = {
  vocab: [
    {en:"the wind", fr:"le vent", alts:["le vent"], needsHyphen:false,
     needsAccent:false, gender:"m", category:"weather"},
    // ... more entries
  ],
  categoryLabels: {
    all:  "Random",
    weather: "Weather",
    seasons: "Seasons",
    // ... one entry per distinct category id used in vocab
  }
};
```

Vocab entry shape (all fields are read by both the multiplayer and solo modes):

| field          | type     | meaning                                                              |
|----------------|----------|----------------------------------------------------------------------|
| `en`           | string   | English prompt shown to the user                                     |
| `fr`           | string   | Canonical French answer (display form)                               |
| `alts`         | string[] | All accepted answer variants (include the canonical form)            |
| `needsHyphen`  | bool     | True if a hyphen is part of the correct answer (strict matching)     |
| `needsAccent`  | bool     | True if an accent is required (strict matching)                      |
| `gender`       | string   | `"m"`, `"f"`, or `"both"`                                            |
| `guessGender`  | bool     | Optional. True if the prompt doesn't already tell you gender         |
| `category`     | string   | Category id; must appear as a key in `categoryLabels`                |

### 2. Register it in `etapes/registry.js`

Add one entry to the `ETAPES` array:

```js
{
  id: 'e3',
  label: 'Étape 3',
  sublabel: '3ᵉ',
  titleMulti: 'French Flashcards · 1v1 MODL-1101 final',
  titleSolo:  'French Flashcards · Solo · MODL-1101 final',
  sub: 'Race a friend, or practice solo',
  file: 'etapes/etape3.js'
}
```

### 3. Update the page maps in **all four** shells

Search-and-replace adds to two small JS objects inside each HTML file:

```js
window.ETAPE_PAGE_MAP = { e1: 'etape1.html', e2: 'index.html', e3: 'etape3.html' };
window.ETAPE_SOLO_MAP = { e1: 'solo1.html',  e2: 'solo.html',  e3: 'solo3.html'  };
```

Do this in `index.html`, `etape1.html`, `solo.html`, `solo1.html` (and the new `etape3.html`,
`solo3.html` you're about to create).

### 4. Create `etape3.html` and `solo3.html`

The fastest way:

- Copy `etape1.html` → `etape3.html`. Change two lines:
  - `window.CURRENT_ETAPE_ID = 'e1';` → `= 'e3';`
  - `<script src="etapes/etape1.js">` → `<script src="etapes/etape3.js">`
- Copy `solo1.html` → `solo3.html`. Same two changes.

### 5. Update `firestore.rules`

If Étape 3 introduces new category ids, add them to the `validCategory` whitelist.
Also extend `validEtape`:

```
function validEtape(e) {
  return e in ['e1', 'e2', 'e3'];
}
```

Then redeploy: `firebase deploy --only firestore:rules`

### 6. (Optional) Change the default landing étape

If you want `index.html` to land on a different étape, change `DEFAULT_ETAPE` at
the bottom of `registry.js`. Note: this is informational right now (each shell
declares its own `CURRENT_ETAPE_ID`). To actually move the default, you'd swap
which étape lives in `index.html` vs the named files.

## How the cross-étape join redirect works

If you're on the Étape 2 lobby (`index.html`) and you type a match code that belongs
to an Étape 1 match, `joinMatch` reads the match doc, sees `etape: 'e1'`, and redirects
you to `etape1.html?code=ABCD` — which auto-joins on load. The reverse works too.
This is why the `etape` field has to be on the match doc and in the security rules.

## What lives in Firestore

The `matches` collection. Each doc is keyed by a 4-letter uppercase code. Document
fields and validation are spelled out in `firestore.rules` — the rules are the source
of truth for what's allowed. Highlights:

- `etape` — `'e1'` or `'e2'` today; extend the rule when adding étapes
- `cards` — array of indices into the étape's `vocab[]` array (so both clients must
  load the same `etape{N}.js` file for the indices to refer to the same words)
- per-player progress: `p1Score`, `p2Score`, `p1Done`, `p2Done`, `p1Time`, `p2Time`,
  `p1Typing`, `p2Typing`
- `status` — `waiting` → `playing` → `done` (or `resigned`)

Writes per match are not optimised. A typical 20-card match produces ~65 Firestore
writes (score updates per card per player, plus typing indicators and done events).
This is intentional — kept as-is for now.

## Local development

It's all static HTML/JS. Open `index.html` in a browser, but note that the étape
scripts are loaded via `<script src="etapes/...">`, which means you need to serve
the files over HTTP (not `file://`) — otherwise the browser will block them. Easy:

```
cd /path/to/project
python3 -m http.server 8000
# then visit http://localhost:8000
```
