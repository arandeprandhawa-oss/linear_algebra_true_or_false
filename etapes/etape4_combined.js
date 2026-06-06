// ============================================================================
// MODL-1101 – Chapitre 2 · La vie quotidienne et les loisirs
// Combined from:
//   etape4_2.js / etape_chapitre2.js  →  2.1 (faire, le temps) + 2.2 (reflexive verbs)
//   etape4_1.js                       →  2.3 (aller, futur proche, places, activities)
//   etape4.js                         →  2.4 (on, sports) + 2.5 (pouvoir, vouloir, savoir)
// Deduplicated: 262 unique fr values; duplicate entries merged with combined alts.
// NOTE: etape4_2.js and etape_chapitre2.js were byte-for-byte identical; only one kept.
// ============================================================================

window.ETAPE_DATA = {
  vocab: [

    // ========================================================================
    // WEATHER EXPRESSIONS – Le temps (2.1)
    // ========================================================================
    {en:"it's nice (weather)",               fr:"il fait beau",                        alts:["il fait beau","fait beau"],                                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},
    {en:"it's warm",                         fr:"il fait chaud",                       alts:["il fait chaud","fait chaud"],                                                            needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},
    {en:"it's sunny",                        fr:"il fait du soleil",                   alts:["il fait du soleil","fait du soleil"],                                                    needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},
    {en:"it's windy",                        fr:"il fait du vent",                     alts:["il fait du vent","fait du vent"],                                                        needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},
    {en:"it's cool",                         fr:"il fait frais",                       alts:["il fait frais","fait frais"],                                                            needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},
    {en:"it's cold",                         fr:"il fait froid",                       alts:["il fait froid","fait froid"],                                                            needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},
    {en:"it's snowing",                      fr:"il neige",                            alts:["il neige","neige"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},
    {en:"it's raining",                      fr:"il pleut",                            alts:["il pleut","pleut"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},
    {en:"it's foggy",                        fr:"il y a du brouillard",                alts:["il y a du brouillard","y a du brouillard"],                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},
    {en:"it's cloudy (the sky is overcast)", fr:"le ciel est couvert",                 alts:["le ciel est couvert","ciel est couvert"],                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"weather"},

    // ========================================================================
    // WEATHER NOUNS – Le temps (2.1)
    // ========================================================================
    {en:"mud",                               fr:"la boue",                             alts:["la boue","boue"],                                                                        needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"weather"},
    {en:"the sky",                           fr:"le ciel",                             alts:["le ciel","ciel"],                                                                        needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"weather"},
    {en:"the climate",                       fr:"le climat",                           alts:["le climat","climat"],                                                                    needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"weather"},
    {en:"snow",                              fr:"la neige",                            alts:["la neige","neige"],                                                                      needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"weather"},
    {en:"a cloud",                           fr:"un nuage",                            alts:["un nuage","nuage"],                                                                      needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"weather"},
    {en:"the sun",                           fr:"le soleil",                           alts:["le soleil","soleil"],                                                                    needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"weather"},

    // ========================================================================
    // SEASONS – Les saisons (2.1)
    // ========================================================================
    {en:"in summer",                         fr:"en été",                              alts:["en été","été"],                                                                          needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"seasons"},
    {en:"in autumn",                         fr:"en automne",                          alts:["en automne","automne"],                                                                  needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"seasons"},
    {en:"in winter",                         fr:"en hiver",                            alts:["en hiver","hiver"],                                                                      needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"seasons"},
    {en:"in spring",                         fr:"au printemps",                        alts:["au printemps","printemps"],                                                              needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"seasons"},

    // ========================================================================
    // PLACES – Les endroits (2.1 preposition phrases; 2.3 nouns; 2.4 destinations)
    // Entries with identical fr merged; best alts union kept.
    // ========================================================================
    // Preposition-phrase forms (2.1)
    {en:"in the country (countryside)",      fr:"à la campagne",                       alts:["à la campagne","campagne"],                                                              needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"places"},
    {en:"at school / to school",             fr:"à l'école",                           alts:["à l'école","école"],                                                                     needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"places"},
    {en:"at the bookstore",                  fr:"à la librairie",                      alts:["à la librairie","librairie"],                                                            needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"places"},
    {en:"at home",                           fr:"à la maison",                         alts:["à la maison","maison"],                                                                  needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"places"},
    {en:"at the market",                     fr:"au marché",                           alts:["au marché","marché"],                                                                    needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"places"},
    {en:"in the fireplace",                  fr:"dans la cheminée",                    alts:["dans la cheminée","cheminée"],                                                           needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"places"},
    {en:"under a tree",                      fr:"sous un arbre",                       alts:["sous un arbre","arbre"],                                                                 needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"places"},
    // Place nouns (2.3)
    {en:"the café",                          fr:"un café",                             alts:["un café","le café"],                                                                     needsHyphen:false, needsAccent:true,  gender:"m", guessGender:true,  category:"places"},
    {en:"the gym",                           fr:"un gymnase",                          alts:["un gymnase","le gymnase"],                                                               needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"places"},
    {en:"the lake",                          fr:"un lac",                              alts:["un lac","le lac"],                                                                       needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"places"},
    {en:"the park",                          fr:"un parc",                             alts:["un parc","le parc"],                                                                     needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"places"},
    {en:"the river",                         fr:"une rivière",                         alts:["une rivière","la rivière"],                                                              needsHyphen:false, needsAccent:true,  gender:"f", guessGender:true,  category:"places"},
    {en:"the university",                    fr:"une université",                      alts:["une université","l'université"],                                                         needsHyphen:false, needsAccent:true,  gender:"f", guessGender:true,  category:"places"},
    {en:"the swimming pool",                 fr:"la piscine",                          alts:["la piscine","piscine"],                                                                  needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"places"},
    {en:"the theatre",                       fr:"le théâtre",                          alts:["le théâtre","théâtre"],                                                                  needsHyphen:false, needsAccent:true,  gender:"m", guessGender:true,  category:"places"},
    {en:"the bar",                           fr:"le bar",                              alts:["le bar","bar"],                                                                          needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"places"},
    {en:"the hospital",                      fr:"l'hôpital",                           alts:["l'hôpital","hôpital"],                                                                   needsHyphen:false, needsAccent:true,  gender:"m", guessGender:true,  category:"places"},
    {en:"the bank",                          fr:"la banque",                           alts:["la banque","banque"],                                                                    needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"places"},
    {en:"the church",                        fr:"l'église",                            alts:["l'église","église"],                                                                     needsHyphen:false, needsAccent:true,  gender:"f", guessGender:true,  category:"places"},
    {en:"the movie theatre / cinema",        fr:"le cinéma",                           alts:["le cinéma","cinéma"],                                                                    needsHyphen:false, needsAccent:true,  gender:"m", guessGender:true,  category:"places"},
    {en:"the shopping mall",                 fr:"le centre commercial",                alts:["le centre commercial","centre commercial"],                                               needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"places"},
    {en:"the restaurant",                    fr:"le restaurant",                       alts:["le restaurant","restaurant"],                                                            needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"places"},
    {en:"the hotel",                         fr:"l'hôtel",                             alts:["l'hôtel","hôtel"],                                                                       needsHyphen:false, needsAccent:true,  gender:"m", guessGender:true,  category:"places"},
    {en:"the beach",                         fr:"la plage",                            alts:["la plage","plage"],                                                                      needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"places"},
    {en:"the forest",                        fr:"la forêt",                            alts:["la forêt","forêt"],                                                                      needsHyphen:false, needsAccent:true,  gender:"f", guessGender:true,  category:"places"},
    {en:"the mountains",                     fr:"la montagne",                         alts:["la montagne","montagne"],                                                                needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"places"},
    // Destination forms – à/au + place (2.4 revision)
    {en:"to the beach",                      fr:"à la plage",                          alts:["à la plage","a la plage"],                                                               needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"places"},
    {en:"to the park",                       fr:"au parc",                             alts:["au parc"],                                                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"places"},
    {en:"to the movies / cinema",            fr:"au cinéma",                           alts:["au cinéma","au cinema"],                                                                 needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"places"},
    {en:"to the gym",                        fr:"au gymnase",                          alts:["au gymnase"],                                                                            needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"places"},
    {en:"to the restaurant",                 fr:"au restaurant",                       alts:["au restaurant"],                                                                         needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"places"},
    {en:"to the mountains",                  fr:"à la montagne",                       alts:["à la montagne","a la montagne"],                                                         needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"places"},
    {en:"to the swimming pool",              fr:"à la piscine",                        alts:["à la piscine","a la piscine"],                                                           needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"places"},
    {en:"to the lake",                       fr:"au lac",                              alts:["au lac"],                                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"places"},
    {en:"to the supermarket",                fr:"au supermarché",                      alts:["au supermarché","au supermarche"],                                                        needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"places"},
    {en:"at friends' place",                 fr:"chez des amis",                       alts:["chez des amis"],                                                                         needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"places"},
    {en:"to the university",                 fr:"à l'université",                      alts:["à l'université","a luniversite","a l'universite"],                                        needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"places"},

    // ========================================================================
    // EXPRESSIONS WITH FAIRE – Sports et loisirs (2.1 + 2.4)
    // Alts merged: include unaccented variants from 2.4 where available.
    // ========================================================================
    {en:"to go canoeing",                    fr:"faire du canoë",                      alts:["faire du canoë","du canoë","canoë","faire du canoe"],                                    needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"faire"},
    {en:"to do errands",                     fr:"faire des courses",                   alts:["faire des courses","des courses","courses"],                                             needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to go rock climbing",               fr:"faire de l'escalade",                 alts:["faire de l'escalade","de l'escalade","escalade","faire de lescalade"],                   needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to fence (to do fencing)",          fr:"faire de l'escrime",                  alts:["faire de l'escrime","de l'escrime","escrime","faire de lescrime"],                       needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to exercise (do gymnastics)",       fr:"faire de la gymnastique",             alts:["faire de la gymnastique","de la gymnastique","gymnastique"],                             needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to ice-skate",                      fr:"faire du patin à glace",              alts:["faire du patin à glace","du patin à glace","patin à glace","faire du patin a glace"],    needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"faire"},
    {en:"to windsurf",                       fr:"faire de la planche à voile",         alts:["faire de la planche à voile","de la planche à voile","planche à voile","faire de la planche a voile"], needsHyphen:false, needsAccent:true, gender:"", guessGender:false, category:"faire"},
    {en:"to scuba dive",                     fr:"faire de la plongée sous-marine",     alts:["faire de la plongée sous-marine","de la plongée sous-marine","plongée sous-marine","faire de la plongee sous-marine"], needsHyphen:true, needsAccent:true, gender:"", guessGender:false, category:"faire"},
    {en:"to go for a (car) ride",            fr:"faire une promenade en voiture",      alts:["faire une promenade en voiture","une promenade en voiture","promenade en voiture"],     needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to take a nap",                     fr:"faire la sieste",                     alts:["faire la sieste","la sieste","sieste"],                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to do sports",                      fr:"faire du sport",                      alts:["faire du sport","du sport","sport"],                                                     needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to bicycle (to bike)",              fr:"faire du vélo",                       alts:["faire du vélo","du vélo","vélo","faire du velo"],                                        needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"faire"},
    {en:"to sail / to go sailing",           fr:"faire de la voile",                   alts:["faire de la voile","de la voile","voile"],                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to go camping",                     fr:"faire du camping",                    alts:["faire du camping","du camping","camping"],                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to party (to celebrate)",           fr:"faire la fête",                       alts:["faire la fête","la fête","fête"],                                                        needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"faire"},
    {en:"to ski",                            fr:"faire du ski",                        alts:["faire du ski","du ski","ski"],                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},
    {en:"to take a walk",                    fr:"faire une promenade",                 alts:["faire une promenade","une promenade","promenade"],                                       needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire"},

    // ========================================================================
    // FAIRE CONJUGATION – Le verbe « faire » (2.1)
    // ========================================================================
    {en:"I do / I make",                     fr:"je fais",                             alts:["je fais","fais"],                                                                        needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire-conj"},
    {en:"you do / you make (tu)",            fr:"tu fais",                             alts:["tu fais","fais"],                                                                        needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire-conj"},
    {en:"he / she / one does / makes",       fr:"il fait",                             alts:["il fait","elle fait","on fait","fait"],                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire-conj"},
    {en:"we do / we make",                   fr:"nous faisons",                        alts:["nous faisons","faisons"],                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire-conj"},
    {en:"you do / you make (vous)",          fr:"vous faites",                         alts:["vous faites","faites"],                                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire-conj"},
    {en:"they do / they make",               fr:"ils font",                            alts:["ils font","elles font","font"],                                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"faire-conj"},

    // ========================================================================
    // PERSONAL CARE NOUNS – Les soins corporels (2.2)
    // ========================================================================
    {en:"a toothbrush",                      fr:"une brosse à dents",                  alts:["une brosse à dents","brosse à dents"],                                                   needsHyphen:false, needsAccent:true,  gender:"f", guessGender:true,  category:"care"},
    {en:"a mirror",                          fr:"un miroir",                           alts:["un miroir","miroir"],                                                                    needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"care"},
    {en:"a razor",                           fr:"un rasoir",                           alts:["un rasoir","rasoir","un rasoir mécanique"],                                              needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"care"},
    {en:"soap",                              fr:"le savon",                            alts:["le savon","savon"],                                                                      needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"care"},
    {en:"shampoo",                           fr:"le shampoing",                        alts:["le shampoing","shampoing"],                                                              needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"care"},

    // ========================================================================
    // REFLEXIVE VERBS – Verbes pronominaux (2.2 + 2.4)
    // se détendre / s'entraîner introduced in 2.4 but grammatically reflexive.
    // ========================================================================
    {en:"to brush one's teeth",              fr:"se brosser les dents",                alts:["se brosser les dents","brosser les dents"],                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to go to bed / to lie down",        fr:"se coucher",                          alts:["se coucher","coucher"],                                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to hurry",                          fr:"se dépêcher",                         alts:["se dépêcher","dépêcher"],                                                                needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"reflexive"},
    {en:"to undress",                        fr:"se déshabiller",                      alts:["se déshabiller","déshabiller"],                                                          needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"reflexive"},
    {en:"to take a shower",                  fr:"se doucher",                          alts:["se doucher","doucher"],                                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to fall asleep",                    fr:"s'endormir",                          alts:["s'endormir","endormir"],                                                                 needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to get dressed",                    fr:"s'habiller",                          alts:["s'habiller","habiller"],                                                                 needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to wash one's face",                fr:"se laver le visage",                  alts:["se laver le visage","laver le visage"],                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to get up",                         fr:"se lever",                            alts:["se lever","lever"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to put on makeup",                  fr:"se maquiller",                        alts:["se maquiller","maquiller"],                                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to take a bath",                    fr:"prendre un bain",                     alts:["prendre un bain","un bain","bain"],                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to shave",                          fr:"se raser",                            alts:["se raser","raser"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to wake up",                        fr:"se réveiller",                        alts:["se réveiller","réveiller"],                                                              needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"reflexive"},
    {en:"to dry oneself",                    fr:"se sécher",                           alts:["se sécher","sécher"],                                                                    needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"reflexive"},
    {en:"to have fun (enjoy oneself)",       fr:"s'amuser",                            alts:["s'amuser","amuser"],                                                                     needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to bathe / to swim",               fr:"se baigner",                          alts:["se baigner","baigner"],                                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to take a walk (stroll)",           fr:"se promener",                         alts:["se promener","promener"],                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to rest",                           fr:"se reposer",                          alts:["se reposer","reposer"],                                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"reflexive"},
    {en:"to relax",                          fr:"se détendre",                         alts:["se détendre","se detendre"],                                                             needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"reflexive"},
    {en:"to work out, to train",             fr:"s'entraîner",                         alts:["s'entraîner","s'entrainer","sentraîner","sentrainer"],                                   needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"reflexive"},

    // ========================================================================
    // TIME & FREQUENCY – Quand et à quelle fréquence (2.2)
    // ce soir / la semaine prochaine appeared in both 2.2 and 2.3; kept here.
    // ========================================================================
    {en:"at the end (of)",                   fr:"à la fin",                            alts:["à la fin","fin","à la fin de"],                                                          needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"time"},
    {en:"before (doing something)",          fr:"avant",                               alts:["avant","avant de"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"this morning",                      fr:"ce matin",                            alts:["ce matin","matin"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"this evening / tonight",            fr:"ce soir",                             alts:["ce soir","soir"],                                                                        needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"first / at first",                  fr:"d'abord",                             alts:["d'abord","abord"],                                                                       needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"early",                             fr:"de bonne heure",                      alts:["de bonne heure","bonne heure"],                                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"usually",                           fr:"d'habitude",                          alts:["d'habitude","habitude"],                                                                 needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"late (delayed)",                    fr:"en retard",                           alts:["en retard","retard"],                                                                    needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"next / then",                       fr:"ensuite",                             alts:["ensuite"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"once (a day)",                      fr:"une fois par jour",                   alts:["une fois par jour","une fois","fois"],                                                   needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"until",                             fr:"jusqu'à",                             alts:["jusqu'à","jusqua"],                                                                      needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"time"},
    {en:"the next day",                      fr:"le lendemain",                        alts:["le lendemain","lendemain"],                                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"on Fridays",                        fr:"le vendredi",                         alts:["le vendredi","vendredi"],                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"on Friday evenings",               fr:"le vendredi soir",                    alts:["le vendredi soir","vendredi soir"],                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"sometimes",                         fr:"parfois",                             alts:["parfois"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"during the week",                   fr:"pendant la semaine",                  alts:["pendant la semaine","la semaine","semaine"],                                             needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"then / next",                       fr:"puis",                                alts:["puis"],                                                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"next week",                         fr:"la semaine prochaine",                alts:["la semaine prochaine","semaine prochaine"],                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"late",                              fr:"tard",                                alts:["tard"],                                                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time"},
    {en:"early (soon)",                      fr:"tôt",                                 alts:["tôt"],                                                                                   needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"time"},

    // ========================================================================
    // FREQUENCY ADVERBS – Adverbes de fréquence (2.2)
    // ========================================================================
    {en:"always",                            fr:"toujours",                            alts:["toujours"],                                                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"frequency"},
    {en:"often",                             fr:"souvent",                             alts:["souvent"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"frequency"},
    {en:"sometimes (frequency)",             fr:"quelquefois",                         alts:["quelquefois"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"frequency"},
    {en:"rarely",                            fr:"rarement",                            alts:["rarement"],                                                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"frequency"},
    {en:"never",                             fr:"jamais",                              alts:["jamais"],                                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"frequency"},

    // ========================================================================
    // VERB ALLER – Le verbe « aller » (2.3)
    // ========================================================================
    {en:"to go",                             fr:"aller",                               alts:["aller"],                                                                                 needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"aller"},
    {en:"I go / I am going",                 fr:"je vais",                             alts:["je vais"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"aller"},
    {en:"you go / you are going (tu)",       fr:"tu vas",                              alts:["tu vas"],                                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"aller"},
    {en:"he goes / he is going",             fr:"il va",                               alts:["il va"],                                                                                 needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"aller"},
    {en:"she goes / she is going",           fr:"elle va",                             alts:["elle va"],                                                                               needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"aller"},
    {en:"one goes / we go (on)",             fr:"on va",                               alts:["on va"],                                                                                 needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"aller"},
    {en:"we go / we are going",              fr:"nous allons",                         alts:["nous allons"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"aller"},
    {en:"you go / you are going (vous)",     fr:"vous allez",                          alts:["vous allez"],                                                                            needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"aller"},
    {en:"they go (masc. or mixed)",          fr:"ils vont",                            alts:["ils vont"],                                                                              needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"aller"},
    {en:"they go (fem.)",                    fr:"elles vont",                          alts:["elles vont"],                                                                            needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"aller"},

    // ========================================================================
    // ALLER + À CONTRACTIONS – « aller à » + les contractions (2.3)
    // ========================================================================
    {en:"to go to (a place)",               fr:"aller à",                             alts:["aller à"],                                                                               needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"contractions"},
    {en:"I am going to the beach",           fr:"je vais à la plage",                  alts:["je vais à la plage"],                                                                    needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"contractions"},
    {en:"I am going to the hotel",           fr:"je vais à l'hôtel",                   alts:["je vais à l'hôtel"],                                                                     needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"contractions"},
    {en:"to the café (à + le = au)",         fr:"au café",                             alts:["au café"],                                                                               needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"contractions"},
    {en:"I am going to the café",            fr:"je vais au café",                     alts:["je vais au café"],                                                                       needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"contractions"},
    {en:"to the Halles (à + les = aux)",     fr:"aux Halles",                          alts:["aux Halles"],                                                                            needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"contractions"},
    {en:"à + le = ?",                        fr:"au",                                  alts:["au"],                                                                                    needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"contractions"},
    {en:"à + les = ?",                       fr:"aux",                                 alts:["aux"],                                                                                   needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"contractions"},
    {en:"at (someone's) house / place",      fr:"chez",                                alts:["chez"],                                                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"contractions"},
    {en:"to eat at Denise's house",          fr:"manger chez Denise",                  alts:["manger chez Denise"],                                                                    needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"contractions"},

    // ========================================================================
    // PRONOUN Y – Le pronom « y » (2.3)
    // ========================================================================
    {en:"there (replaces « à » + place)",    fr:"y",                                   alts:["y"],                                                                                     needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pronoun_y"},
    {en:"Is he going to Paris?",             fr:"Il va à Paris ?",                     alts:["Il va à Paris","Il va à Paris ?","Il va à Paris?"],                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pronoun_y"},
    {en:"He goes there.",                    fr:"Il y va.",                            alts:["Il y va","Il y va."],                                                                    needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pronoun_y"},
    {en:"Are they going to the restaurant? (fem.)", fr:"Elles vont au restaurant ?",   alts:["Elles vont au restaurant","Elles vont au restaurant ?"],                                needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"pronoun_y"},
    {en:"They go there. (fem.)",             fr:"Elles y vont.",                       alts:["Elles y vont","Elles y vont."],                                                          needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"pronoun_y"},
    {en:"Are you going to the café? (tu)",   fr:"Tu vas au café ?",                    alts:["Tu vas au café","Tu vas au café ?"],                                                     needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"pronoun_y"},
    {en:"Yes, I am going there!",            fr:"Oui, j'y vais !",                     alts:["Oui, j'y vais","Oui, j'y vais !","Oui, j'y vais!"],                                    needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pronoun_y"},
    {en:"Do you often go to the beach? (tu)", fr:"Vas-tu souvent à la plage ?",        alts:["Vas-tu souvent à la plage","Vas-tu souvent à la plage ?"],                               needsHyphen:true,  needsAccent:true,  gender:"",  guessGender:false, category:"pronoun_y"},
    {en:"I go there often.",                 fr:"J'y vais souvent.",                   alts:["J'y vais souvent","J'y vais souvent."],                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pronoun_y"},
    {en:"No, I don't go there.",             fr:"Non, je n'y vais pas.",               alts:["Non, je n'y vais pas","Non, je n'y vais pas."],                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pronoun_y"},

    // ========================================================================
    // FUTUR PROCHE – aller + infinitif (2.3)
    // ========================================================================
    {en:"I am going to have dinner at the restaurant tonight.",       fr:"Je vais dîner au restaurant ce soir.",            alts:["Je vais dîner au restaurant ce soir","Je vais dîner au restaurant ce soir."],                                       needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"futur_proche"},
    {en:"My husband and I are going to eat at Denise's.",             fr:"Mon mari et moi allons manger chez Denise.",       alts:["Mon mari et moi allons manger chez Denise","Mon mari et moi allons manger chez Denise."],                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"futur_proche"},
    {en:"Tomorrow evening, I am going to have dinner at the restaurant.", fr:"Demain soir, je vais dîner au restaurant.",  alts:["Demain soir, je vais dîner au restaurant","Demain soir, je vais dîner au restaurant."],                            needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"futur_proche"},
    {en:"Next Sunday, I am going to go skiing.",                      fr:"Dimanche prochain, je vais faire du ski.",        alts:["Dimanche prochain, je vais faire du ski","Dimanche prochain, je vais faire du ski."],                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"futur_proche"},
    {en:"In two years, I am going to visit my family.",               fr:"Dans deux ans, je vais visiter ma famille.",      alts:["Dans deux ans, je vais visiter ma famille","Dans deux ans, je vais visiter ma famille."],                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"futur_proche"},
    {en:"Tonight, I am going to do the cooking.",                     fr:"Ce soir, je vais faire la cuisine.",              alts:["Ce soir, je vais faire la cuisine","Ce soir, je vais faire la cuisine."],                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"futur_proche"},
    {en:"Tonight, I am going to do the grocery shopping.",            fr:"Ce soir, je vais faire les courses.",             alts:["Ce soir, je vais faire les courses","Ce soir, je vais faire les courses."],                                        needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"futur_proche"},
    {en:"Tonight, I am not going to do the grocery shopping.",        fr:"Ce soir, je ne vais pas faire les courses.",      alts:["Ce soir, je ne vais pas faire les courses","Ce soir, je ne vais pas faire les courses."],                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"futur_proche"},

    // ========================================================================
    // FUTURE TIME EXPRESSIONS – Le futur : quand ? (2.3)
    // ce soir / la semaine prochaine already listed under "time" above.
    // ========================================================================
    {en:"tomorrow",                          fr:"demain",                              alts:["demain"],                                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time_future"},
    {en:"tomorrow morning",                  fr:"demain matin",                        alts:["demain matin"],                                                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time_future"},
    {en:"tomorrow evening",                  fr:"demain soir",                         alts:["demain soir"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time_future"},
    {en:"next Saturday",                     fr:"samedi prochain",                     alts:["samedi prochain"],                                                                       needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time_future"},
    {en:"next year",                         fr:"l'année prochaine",                   alts:["l'année prochaine"],                                                                     needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"time_future"},
    {en:"in a month",                        fr:"dans un mois",                        alts:["dans un mois"],                                                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"time_future"},
    {en:"this weekend",                      fr:"ce week-end",                         alts:["ce week-end"],                                                                           needsHyphen:true,  needsAccent:false, gender:"",  guessGender:false, category:"time_future"},

    // ========================================================================
    // ACTIVITIES – Activités (2.3)
    // Duplicates with faire/reflexive removed; surfer/pêcher/nager merged alts.
    // ========================================================================
    {en:"to surf the Internet",              fr:"surfer sur Internet",                 alts:["surfer sur Internet","surfer sur internet"],                                             needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},
    {en:"to listen to music",                fr:"écouter de la musique",               alts:["écouter de la musique"],                                                                 needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"activities"},
    {en:"to study",                          fr:"étudier",                             alts:["étudier"],                                                                               needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"activities"},
    {en:"to buy books",                      fr:"acheter des livres",                  alts:["acheter des livres"],                                                                    needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},
    {en:"to do the grocery shopping",        fr:"faire les courses",                   alts:["faire les courses"],                                                                     needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},
    {en:"to play basketball",                fr:"jouer au basket",                     alts:["jouer au basket","jouer au basketball"],                                                 needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},
    {en:"to have lunch",                     fr:"déjeuner",                            alts:["déjeuner"],                                                                              needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"activities"},
    {en:"to fish",                           fr:"pêcher",                              alts:["pêcher","pecher"],                                                                       needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"activities"},
    {en:"to swim",                           fr:"nager",                               alts:["nager"],                                                                                 needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},
    {en:"to see one's friends",              fr:"voir ses amis",                       alts:["voir ses amis"],                                                                         needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},
    {en:"to see a film",                     fr:"voir un film",                        alts:["voir un film"],                                                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},
    {en:"to go shopping (purchases)",        fr:"faire des achats",                    alts:["faire des achats"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},
    {en:"to buy clothes",                    fr:"acheter des vêtements",               alts:["acheter des vêtements"],                                                                 needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"activities"},
    {en:"to have dinner",                    fr:"dîner",                               alts:["dîner"],                                                                                 needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"activities"},
    {en:"to chat, to discuss",               fr:"discuter",                            alts:["discuter"],                                                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},
    {en:"to read a good novel",              fr:"lire un bon roman",                   alts:["lire un bon roman"],                                                                     needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"activities"},

    // ========================================================================
    // DAILY ROUTINE SENTENCES – Révision verbes pronominaux (2.3)
    // ========================================================================
    {en:"He brushes his teeth.",             fr:"Il se brosse les dents.",             alts:["Il se brosse les dents","Il se brosse les dents."],                                      needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"routine"},
    {en:"He shaves.",                        fr:"Il se rase.",                         alts:["Il se rase","Il se rase."],                                                              needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"routine"},
    {en:"He showers.",                       fr:"Il se douche.",                       alts:["Il se douche","Il se douche."],                                                          needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"routine"},
    {en:"He gets dressed.",                  fr:"Il s'habille.",                       alts:["Il s'habille","Il s'habille."],                                                          needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"routine"},
    {en:"He hurries.",                       fr:"Il se dépêche.",                      alts:["Il se dépêche","Il se dépêche."],                                                        needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"routine"},
    {en:"She wakes up at 6 o'clock.",        fr:"Elle se réveille à 6h.",              alts:["Elle se réveille à 6h","Elle se réveille à 6h."],                                       needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"routine"},

    // ========================================================================
    // QUESTIONS & HABITS (2.3)
    // ========================================================================
    {en:"What is he doing?",                 fr:"Que fait-il ?",                       alts:["Que fait-il","Que fait-il ?","Que fait-il?"],                                            needsHyphen:true,  needsAccent:false, gender:"",  guessGender:false, category:"questions"},
    {en:"What are they going to do?",        fr:"Qu'est-ce qu'ils vont faire ?",       alts:["Qu'est-ce qu'ils vont faire","Qu'est-ce qu'ils vont faire ?"],                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"questions"},
    {en:"Christine goes to the park after dinner.", fr:"Christine va au parc après le dîner.", alts:["Christine va au parc après le dîner","Christine va au parc après le dîner."], needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"questions"},
    {en:"She likes to go for walks.",        fr:"Elle aime se promener.",              alts:["Elle aime se promener","Elle aime se promener."],                                        needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"questions"},

    // ========================================================================
    // SPORTS & LOISIRS – Additional (2.4)
    // Faire expressions already in "faire" above; unique sports entries only.
    // ========================================================================
    {en:"to learn to (swim)",               fr:"apprendre à (nager)",                 alts:["apprendre à nager","apprendre a nager"],                                                 needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"sports"},
    {en:"to chat with friends",             fr:"bavarder avec des amis",              alts:["bavarder avec des amis"],                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"sports"},
    {en:"to run",                           fr:"courir",                              alts:["courir"],                                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"sports"},
    {en:"to create a web page",             fr:"créer une page web",                  alts:["créer une page web","creer une page web"],                                               needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"sports"},
    {en:"to celebrate a birthday",         fr:"fêter un anniversaire",               alts:["fêter un anniversaire","feter un anniversaire"],                                         needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"sports"},
    {en:"to play frisbee",                  fr:"jouer au frisbee",                    alts:["jouer au frisbee"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"sports"},
    {en:"to play the piano",                fr:"jouer du piano",                      alts:["jouer du piano"],                                                                        needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"sports"},
    {en:"to ride a horse; horseback riding", fr:"monter à cheval",                   alts:["monter à cheval","monter a cheval"],                                                      needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"sports"},
    {en:"to take the city bus",             fr:"prendre l'autobus",                   alts:["prendre l'autobus","prendre lautobus"],                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"sports"},
    {en:"to dream of (traveling)",          fr:"rêver de (voyager)",                  alts:["rêver de voyager","rever de voyager"],                                                   needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"sports"},
    {en:"to escape the daily grind",        fr:"sortir de la routine quotidienne",    alts:["sortir de la routine quotidienne"],                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"sports"},
    {en:"to explore",                       fr:"explorer",                            alts:["explorer"],                                                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"sports"},
    {en:"to pilot, to fly",                 fr:"piloter",                             alts:["piloter"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"sports"},
    {en:"to have a picnic",                 fr:"pique-niquer",                        alts:["pique-niquer","piqueniquer"],                                                             needsHyphen:true,  needsAccent:false, gender:"",  guessGender:false, category:"sports"},
    {en:"to dance",                         fr:"danser",                              alts:["danser"],                                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"sports"},

    // ========================================================================
    // POUVOIR – to be able to, can (2.5)
    // ========================================================================
    {en:"I can / am able to",               fr:"je peux",                             alts:["je peux"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pouvoir"},
    {en:"you can (tu)",                     fr:"tu peux",                             alts:["tu peux"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pouvoir"},
    {en:"he / she / one can",               fr:"il/elle/on peut",                     alts:["il peut","elle peut","on peut","il/elle/on peut"],                                       needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pouvoir"},
    {en:"we can",                           fr:"nous pouvons",                        alts:["nous pouvons"],                                                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pouvoir"},
    {en:"you can (vous)",                   fr:"vous pouvez",                         alts:["vous pouvez"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pouvoir"},
    {en:"they can",                         fr:"ils/elles peuvent",                   alts:["ils peuvent","elles peuvent","ils/elles peuvent"],                                       needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"pouvoir"},

    // ========================================================================
    // VOULOIR – to want (2.5)
    // ========================================================================
    {en:"I want",                           fr:"je veux",                             alts:["je veux"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"you want (tu)",                    fr:"tu veux",                             alts:["tu veux"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"he / she / one wants",             fr:"il/elle/on veut",                     alts:["il veut","elle veut","on veut","il/elle/on veut"],                                       needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"we want",                          fr:"nous voulons",                        alts:["nous voulons"],                                                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"you want (vous)",                  fr:"vous voulez",                         alts:["vous voulez"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"they want",                        fr:"ils/elles veulent",                   alts:["ils veulent","elles veulent","ils/elles veulent"],                                       needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"I would like (polite)",            fr:"je voudrais",                         alts:["je voudrais"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"you would like (tu)",              fr:"tu voudrais",                         alts:["tu voudrais"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"he / she would like",              fr:"il/elle voudrait",                    alts:["il voudrait","elle voudrait","il/elle voudrait"],                                        needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"I would like (j'aimerais)",        fr:"j'aimerais",                          alts:["j'aimerais","jaimerais"],                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"you would like (tu aimerais)",     fr:"tu aimerais",                         alts:["tu aimerais"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},
    {en:"he / she would like (aimerait)",   fr:"il/elle aimerait",                    alts:["il aimerait","elle aimerait","il/elle aimerait"],                                        needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"vouloir"},

    // ========================================================================
    // SAVOIR – to know (a fact / how to do) (2.5)
    // ========================================================================
    {en:"I know (how to)",                  fr:"je sais",                             alts:["je sais"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"savoir"},
    {en:"you know (tu)",                    fr:"tu sais",                             alts:["tu sais"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"savoir"},
    {en:"he / she / one knows",             fr:"il/elle/on sait",                     alts:["il sait","elle sait","on sait","il/elle/on sait"],                                       needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"savoir"},
    {en:"we know",                          fr:"nous savons",                         alts:["nous savons"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"savoir"},
    {en:"you know (vous)",                  fr:"vous savez",                          alts:["vous savez"],                                                                            needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"savoir"},
    {en:"they know",                        fr:"ils/elles savent",                    alts:["ils savent","elles savent","ils/elles savent"],                                          needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"savoir"},

    // ========================================================================
    // DEGREE ADVERBS – How well you do something (2.4)
    // ========================================================================
    {en:"very well",                        fr:"très bien",                           alts:["très bien","tres bien"],                                                                 needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"degree"},
    {en:"more or less",                     fr:"plus ou moins",                       alts:["plus ou moins"],                                                                         needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"degree"},
    {en:"badly, not well",                  fr:"mal",                                 alts:["mal"],                                                                                   needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"degree"},
    {en:"a little",                         fr:"un peu",                              alts:["un peu"],                                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"degree"},
    {en:"very little",                      fr:"très peu",                            alts:["très peu","tres peu"],                                                                   needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"degree"},
    {en:"not at all",                       fr:"pas du tout",                         alts:["pas du tout"],                                                                           needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"degree"},

    // ========================================================================
    // PRONOUN ON – Le pronom « on » (2.4)
    // ========================================================================
    {en:"we can go to the movies tonight",                    fr:"on peut aller au cinéma ce soir",    alts:["on peut aller au cinéma ce soir","on peut aller au cinema ce soir"],    needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"on"},
    {en:"we want to wash our hands",                          fr:"on veut se laver les mains",         alts:["on veut se laver les mains"],                                            needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"on"},
    {en:"in the U.S., one doesn't go to school on Saturday", fr:"on ne va pas à l'école le samedi",   alts:["on ne va pas à l'école le samedi","on ne va pas a lecole le samedi"],   needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"on"},

    // ========================================================================
    // INFINITIVES – verbs used with pouvoir / vouloir / savoir (2.5)
    // nager kept under "activities" above (introduced earlier in 2.3).
    // ========================================================================
    {en:"to drive",                         fr:"conduire",                            alts:["conduire"],                                                                              needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to travel",                        fr:"voyager",                             alts:["voyager"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to leave / set off (for)",         fr:"partir",                              alts:["partir"],                                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to become",                        fr:"devenir",                             alts:["devenir"],                                                                               needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to go out",                        fr:"sortir",                              alts:["sortir"],                                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to read",                          fr:"lire",                                alts:["lire"],                                                                                  needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to play cards",                    fr:"jouer aux cartes",                    alts:["jouer aux cartes"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to light a fire",                  fr:"allumer un feu",                      alts:["allumer un feu"],                                                                        needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to repair a car",                  fr:"réparer une voiture",                 alts:["réparer une voiture","reparer une voiture"],                                             needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"infinitives"},
    {en:"to use a computer",                fr:"utiliser un ordinateur",              alts:["utiliser un ordinateur"],                                                                needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to play billiards / pool",         fr:"jouer au billard",                    alts:["jouer au billard"],                                                                      needsHyphen:false, needsAccent:false, gender:"",  guessGender:false, category:"infinitives"},
    {en:"to buy fruit at the market",       fr:"acheter des fruits au marché",        alts:["acheter des fruits au marché","acheter des fruits au marche"],                           needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"infinitives"},
    {en:"to count to ten",                  fr:"compter jusqu'à dix",                 alts:["compter jusqu'à dix","compter jusqua dix","compter jusqu'a dix"],                        needsHyphen:false, needsAccent:true,  gender:"",  guessGender:false, category:"infinitives"},

  ],
  categoryLabels: {
    all:            "Random",
    weather:        "Weather (le temps)",
    seasons:        "Seasons (les saisons)",
    places:         "Places (les endroits)",
    faire:          "Faire expressions",
    "faire-conj":   "Verb « faire »",
    care:           "Personal care",
    reflexive:      "Reflexive verbs",
    time:           "Time expressions",
    frequency:      "Frequency adverbs",
    aller:          "Verb « aller »",
    contractions:   "Aller + à (contractions)",
    pronoun_y:      "Pronoun « y »",
    futur_proche:   "Futur proche",
    time_future:    "Future time expressions",
    activities:     "Activities",
    routine:        "Daily routine",
    questions:      "Questions & habits",
    sports:         "Sports & loisirs",
    pouvoir:        "Pouvoir (can)",
    vouloir:        "Vouloir (want)",
    savoir:         "Savoir (know)",
    degree:         "How well",
    on:             "Le pronom « on »",
    infinitives:    "Infinitifs"
  }
};
