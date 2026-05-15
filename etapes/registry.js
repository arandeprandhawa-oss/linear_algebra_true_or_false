// =====================================================================
// ÉTAPE REGISTRY — the single source of truth for all étapes
// =====================================================================
// HOW TO ADD A NEW ÉTAPE (e.g. Étape 3):
//   1. Create /etapes/etape3.js with the same shape as etape1.js / etape2.js:
//        - window.ETAPE_DATA = {
//            vocab: [...],          // your vocab entries
//            categoryLabels: {...}, // category id -> display label
//          };
//   2. Add a new entry to the ETAPES array below (just one object).
//   3. If etape3 introduces new category ids that aren't already in the
//      Firestore rules whitelist, add them to firestore.rules and redeploy.
//   4. Done. The tab bar, lobby, solo page, and category chips all read
//      from this registry automatically.
//
// To change which tab is the default landing tab, change DEFAULT_ETAPE.
// =====================================================================

window.ETAPES = [
  {
    id: 'e1',
    label: 'Étape 1',
    sublabel: '1ʳᵉ',
    titleMulti: 'French Flashcards · 1v1 MODL-1101 1st midterm',
    titleSolo:  'French Flashcards · Solo · MODL-1101 1st midterm',
    sub: 'Race a friend, or practice solo',
    file: 'etapes/etape1.js'
  },
  {
    id: 'e2',
    label: 'Étape 2',
    sublabel: '2ᵉ',
    titleMulti: 'French Flashcards · 1v1 MODL-1101 2nd midterm',
    titleSolo:  'French Flashcards · Solo · MODL-1101 2nd midterm',
    sub: 'Race a friend, or practice solo',
    file: 'etapes/etape2.js'
  }
];

window.DEFAULT_ETAPE = 'e2';
