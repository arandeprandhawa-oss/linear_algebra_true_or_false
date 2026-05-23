// =====================================================================
// MODL-1101 — Chapitre 1 · Ma famille et moi
// Merged from flashcards_week4_class13.js (Class 13, section 1.1),
//             flashcards_week4.js        (Classes 14-15, sections 1.2-1.5),
//             vocab_chapitre1.js         (Classes 16-17)
// Cleaned: strict accents, no "/" combined forms, no "...", masculine
//          and feminine separated and individually labelled.
// =====================================================================

window.CHAPITRE1_DATA = {
  vocab: [

    // ==================================================================
    // FAMILY MEMBERS — La famille
    // ==================================================================
    {en:"the husband",                       fr:"le mari",                alts:["le mari","mari"],                              needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"family"},
    {en:"the wife",                          fr:"la femme",               alts:["la femme","femme"],                            needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"family"},
    {en:"the spouse (masc.)",                fr:"l'époux",                alts:["l'époux","époux"],                             needsHyphen:false, needsAccent:true,  gender:"m", guessGender:true,  category:"family"},
    {en:"the spouse (fem.)",                 fr:"l'épouse",               alts:["l'épouse","épouse"],                           needsHyphen:false, needsAccent:true,  gender:"f", guessGender:true,  category:"family"},
    {en:"the father",                        fr:"le père",                alts:["le père","père"],                              needsHyphen:false, needsAccent:true,  gender:"m", guessGender:true,  category:"family"},
    {en:"the mother",                        fr:"la mère",                alts:["la mère","mère"],                              needsHyphen:false, needsAccent:true,  gender:"f", guessGender:true,  category:"family"},
    {en:"the son",                           fr:"le fils",                alts:["le fils","fils"],                              needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"family"},
    {en:"the daughter",                      fr:"la fille",               alts:["la fille","fille"],                            needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"family"},
    {en:"the brother",                       fr:"le frère",               alts:["le frère","frère"],                            needsHyphen:false, needsAccent:true,  gender:"m", guessGender:true,  category:"family"},
    {en:"the sister",                        fr:"la sœur",                alts:["la sœur","sœur"],                              needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"family"},
    {en:"the grandfather",                   fr:"le grand-père",          alts:["le grand-père","grand-père"],                  needsHyphen:true,  needsAccent:true,  gender:"m", guessGender:true,  category:"family"},
    {en:"the grandmother",                   fr:"la grand-mère",          alts:["la grand-mère","grand-mère"],                  needsHyphen:true,  needsAccent:true,  gender:"f", guessGender:true,  category:"family"},
    {en:"the grandparents",                  fr:"les grands-parents",     alts:["les grands-parents","grands-parents"],         needsHyphen:true,  needsAccent:false, gender:"m", guessGender:false, category:"family"},
    {en:"the grandson",                      fr:"le petit-fils",          alts:["le petit-fils","petit-fils"],                  needsHyphen:true,  needsAccent:false, gender:"m", guessGender:true,  category:"family"},
    {en:"the granddaughter",                 fr:"la petite-fille",        alts:["la petite-fille","petite-fille"],              needsHyphen:true,  needsAccent:false, gender:"f", guessGender:true,  category:"family"},
    {en:"the grandchildren",                 fr:"les petits-enfants",     alts:["les petits-enfants","petits-enfants"],         needsHyphen:true,  needsAccent:false, gender:"m", guessGender:false, category:"family"},
    {en:"the uncle",                         fr:"l'oncle",                alts:["l'oncle","oncle"],                             needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"family"},
    {en:"the aunt",                          fr:"la tante",               alts:["la tante","tante"],                            needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"family"},
    {en:"the cousin (masc.)",                fr:"le cousin",              alts:["le cousin","cousin"],                          needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"family"},
    {en:"the cousin (fem.)",                 fr:"la cousine",             alts:["la cousine","cousine"],                        needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"family"},
    {en:"the nephew",                        fr:"le neveu",               alts:["le neveu","neveu"],                            needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"family"},
    {en:"the niece",                         fr:"la nièce",               alts:["la nièce","nièce"],                            needsHyphen:false, needsAccent:true,  gender:"f", guessGender:true,  category:"family"},
    {en:"the brother-in-law",                fr:"le beau-frère",          alts:["le beau-frère","beau-frère"],                  needsHyphen:true,  needsAccent:true,  gender:"m", guessGender:true,  category:"family"},
    {en:"the sister-in-law",                 fr:"la belle-sœur",          alts:["la belle-sœur","belle-sœur"],                  needsHyphen:true,  needsAccent:false, gender:"f", guessGender:true,  category:"family"},
    {en:"the father-in-law (also stepfather)", fr:"le beau-père",         alts:["le beau-père","beau-père"],                    needsHyphen:true,  needsAccent:true,  gender:"m", guessGender:true,  category:"family"},
    {en:"the mother-in-law (also stepmother)", fr:"la belle-mère",        alts:["la belle-mère","belle-mère"],                  needsHyphen:true,  needsAccent:true,  gender:"f", guessGender:true,  category:"family"},
    {en:"the half brother (also stepbrother)", fr:"le demi-frère",        alts:["le demi-frère","demi-frère"],                  needsHyphen:true,  needsAccent:true,  gender:"m", guessGender:true,  category:"family"},
    {en:"the half sister (also stepsister)", fr:"la demi-sœur",           alts:["la demi-sœur","demi-sœur"],                    needsHyphen:true,  needsAccent:false, gender:"f", guessGender:true,  category:"family"},
    {en:"the child",                         fr:"l'enfant",               alts:["l'enfant","enfant"],                           needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"family"},
    {en:"the children",                      fr:"les enfants",            alts:["les enfants","enfants"],                       needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"family"},
    {en:"the parents",                       fr:"les parents",            alts:["les parents","parents"],                       needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"family"},
    {en:"the twins (masc. or mixed)",        fr:"les jumeaux",            alts:["les jumeaux","jumeaux"],                       needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"family"},
    {en:"the twins (fem.)",                  fr:"les jumelles",           alts:["les jumelles","jumelles"],                     needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"family"},

    // ==================================================================
    // RELATIONSHIPS — Vocabulaire utile (relations)
    // ==================================================================
    {en:"the friend (masc.)",                fr:"le copain",              alts:["le copain","copain"],                          needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"relationships"},
    {en:"the friend (fem.)",                 fr:"la copine",              alts:["la copine","copine"],                          needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"relationships"},
    {en:"the boyfriend",                     fr:"le petit ami",           alts:["le petit ami"],                                needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"relationships"},
    {en:"the girlfriend",                    fr:"la petite amie",         alts:["la petite amie"],                              needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"relationships"},
    {en:"the roommate (masc.)",              fr:"le camarade de chambre", alts:["le camarade de chambre"],                      needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"relationships"},
    {en:"the roommate (fem.)",               fr:"la camarade de chambre", alts:["la camarade de chambre"],                      needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"relationships"},
    {en:"the classmate (masc.)",             fr:"le camarade de classe",  alts:["le camarade de classe"],                       needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"relationships"},
    {en:"the classmate (fem.)",              fr:"la camarade de classe",  alts:["la camarade de classe"],                       needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"relationships"},
    {en:"single, unmarried",                 fr:"célibataire",            alts:["célibataire"],                                 needsHyphen:false, needsAccent:true,  gender:"both", guessGender:false, category:"relationships"},
    {en:"alone, by oneself (masc.)",         fr:"seul",                   alts:["seul"],                                        needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"relationships"},
    {en:"alone, by oneself (fem.)",          fr:"seule",                  alts:["seule"],                                       needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"relationships"},

    // ==================================================================
    // FAMILY QUESTIONS & PHRASES — Questions sur la famille
    // ==================================================================
    {en:"How old are you?",                  fr:"Quel âge as-tu ?",       alts:["Quel âge as-tu","Quel âge as-tu ?","Quel âge as-tu?"], needsHyphen:true,  needsAccent:true,  gender:"both", category:"family_phrases"},
    {en:"I am six years old.",               fr:"J'ai six ans.",          alts:["J'ai six ans","J'ai six ans."],                needsHyphen:false, needsAccent:false, gender:"both", category:"family_phrases"},
    {en:"How many people are in your family?", fr:"Combien de personnes y a-t-il dans ta famille ?", alts:["Combien de personnes y a-t-il dans ta famille","Combien de personnes y a-t-il dans ta famille ?"], needsHyphen:true, needsAccent:false, gender:"both", category:"family_phrases"},
    {en:"There are four people.",            fr:"Il y a quatre personnes.", alts:["Il y a quatre personnes","Il y a quatre personnes."], needsHyphen:false, needsAccent:false, gender:"both", category:"family_phrases"},
    {en:"What are your family members called?", fr:"Comment s'appellent les membres de ta famille ?", alts:["Comment s'appellent les membres de ta famille","Comment s'appellent les membres de ta famille ?"], needsHyphen:false, needsAccent:false, gender:"both", category:"family_phrases"},
    {en:"How old are they?",                 fr:"Quel âge ont-ils ?",     alts:["Quel âge ont-ils","Quel âge ont-ils ?","Quel âge ont-ils?"], needsHyphen:true, needsAccent:true, gender:"both", category:"family_phrases"},
    {en:"What is your family like?",         fr:"Comment est ta famille ?", alts:["Comment est ta famille","Comment est ta famille ?"], needsHyphen:false, needsAccent:false, gender:"both", category:"family_phrases"},
    {en:"What is Claudine's mother called?", fr:"Comment s'appelle la mère de Claudine ?", alts:["Comment s'appelle la mère de Claudine","Comment s'appelle la mère de Claudine ?"], needsHyphen:false, needsAccent:true, gender:"both", category:"family_phrases"},
    {en:"How old is Charles?",               fr:"Quel âge a Charles ?",   alts:["Quel âge a Charles","Quel âge a Charles ?"],   needsHyphen:false, needsAccent:true,  gender:"both", category:"family_phrases"},
    {en:"Who is Joël?",                      fr:"Qui est Joël ?",         alts:["Qui est Joël","Qui est Joël ?"],               needsHyphen:false, needsAccent:true,  gender:"both", category:"family_phrases"},
    {en:"He is the grandson of Francis and Marie.", fr:"C'est le petit-fils de Francis et Marie.", alts:["C'est le petit-fils de Francis et Marie","C'est le petit-fils de Francis et Marie."], needsHyphen:true, needsAccent:false, gender:"both", category:"family_phrases"},

    // ==================================================================
    // DESCRIBING PEOPLE — La description (adjectives)
    // ==================================================================
    {en:"good (masc.)",                      fr:"bon",                    alts:["bon"],                                         needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"description"},
    {en:"good (fem.)",                       fr:"bonne",                  alts:["bonne"],                                       needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"description"},
    {en:"hip, cool (masc.)",                 fr:"branché",                alts:["branché"],                                     needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"description"},
    {en:"hip, cool (fem.)",                  fr:"branchée",               alts:["branchée"],                                    needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"description"},
    {en:"understanding (masc.)",             fr:"compréhensif",           alts:["compréhensif"],                                needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"description"},
    {en:"understanding (fem.)",              fr:"compréhensive",          alts:["compréhensive"],                               needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"description"},
    {en:"twin (masc.)",                      fr:"jumeau",                 alts:["jumeau"],                                      needsHyphen:false, needsAccent:false, gender:"m", guessGender:true,  category:"description"},
    {en:"twin (fem.)",                       fr:"jumelle",                alts:["jumelle"],                                     needsHyphen:false, needsAccent:false, gender:"f", guessGender:true,  category:"description"},
    {en:"deceased, dead (masc.)",            fr:"mort",                   alts:["mort"],                                        needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"description"},
    {en:"deceased, dead (fem.)",             fr:"morte",                  alts:["morte"],                                       needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"description"},
    {en:"numerous (masc.)",                  fr:"nombreux",               alts:["nombreux"],                                    needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"description"},
    {en:"numerous (fem.)",                   fr:"nombreuse",              alts:["nombreuse"],                                   needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"description"},
    {en:"polite (masc.)",                    fr:"poli",                   alts:["poli"],                                        needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"description"},
    {en:"polite (fem.)",                     fr:"polie",                  alts:["polie"],                                       needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"description"},
    {en:"all, every (masc.)",                fr:"tout",                   alts:["tout"],                                        needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"description"},
    {en:"all, every (fem.)",                 fr:"toute",                  alts:["toute"],                                       needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"description"},
    {en:"too, too much",                     fr:"trop",                   alts:["trop"],                                        needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"description"},
    {en:"old-fashioned",                     fr:"vieux jeu",              alts:["vieux jeu"],                                   needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"description"},
    {en:"quickly",                           fr:"vite",                   alts:["vite"],                                        needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"description"},
    {en:"living, alive (masc.)",             fr:"vivant",                 alts:["vivant"],                                      needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"description"},
    {en:"living, alive (fem.)",              fr:"vivante",                alts:["vivante"],                                     needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"description"},

    // ==================================================================
    // COGNATE ADJECTIVES — Mots apparentés
    // ==================================================================
    {en:"affectionate (masc.)",              fr:"affectueux",             alts:["affectueux"],                                  needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"cognates"},
    {en:"affectionate (fem.)",               fr:"affectueuse",            alts:["affectueuse"],                                 needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"cognates"},
    {en:"ambitious (masc.)",                 fr:"ambitieux",              alts:["ambitieux"],                                   needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"cognates"},
    {en:"ambitious (fem.)",                  fr:"ambitieuse",             alts:["ambitieuse"],                                  needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"cognates"},
    {en:"attentively",                       fr:"attentivement",          alts:["attentivement"],                               needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"cognates"},
    {en:"calm",                              fr:"calme",                  alts:["calme"],                                       needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"cognates"},
    {en:"discreet (masc.)",                  fr:"discret",                alts:["discret"],                                     needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"cognates"},
    {en:"discreet (fem.)",                   fr:"discrète",               alts:["discrète"],                                    needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"cognates"},
    {en:"favourite (masc.)",                 fr:"favori",                 alts:["favori"],                                      needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"cognates"},
    {en:"favourite (fem.)",                  fr:"favorite",               alts:["favorite"],                                    needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"cognates"},
    {en:"flexible",                          fr:"flexible",               alts:["flexible"],                                    needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"cognates"},
    {en:"generous (masc.)",                  fr:"généreux",               alts:["généreux"],                                    needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"cognates"},
    {en:"generous (fem.)",                   fr:"généreuse",              alts:["généreuse"],                                   needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"cognates"},
    {en:"modern",                            fr:"moderne",                alts:["moderne"],                                     needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"cognates"},
    {en:"organised (masc.)",                 fr:"organisé",               alts:["organisé"],                                    needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"cognates"},
    {en:"organised (fem.)",                  fr:"organisée",              alts:["organisée"],                                   needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"cognates"},
    {en:"patient (masc.)",                   fr:"patient",                alts:["patient"],                                     needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"cognates"},
    {en:"patient (fem.)",                    fr:"patiente",               alts:["patiente"],                                    needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"cognates"},
    {en:"physically",                        fr:"physiquement",           alts:["physiquement"],                                needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"cognates"},
    {en:"realistic",                         fr:"réaliste",               alts:["réaliste"],                                    needsHyphen:false, needsAccent:true,  gender:"both", guessGender:false, category:"cognates"},
    {en:"reserved (masc.)",                  fr:"réservé",                alts:["réservé"],                                     needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"cognates"},
    {en:"reserved (fem.)",                   fr:"réservée",               alts:["réservée"],                                    needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"cognates"},
    {en:"athletic, sporty (masc.)",          fr:"sportif",                alts:["sportif"],                                     needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"cognates"},
    {en:"athletic, sporty (fem.)",           fr:"sportive",               alts:["sportive"],                                    needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"cognates"},
    {en:"strict (masc.)",                    fr:"strict",                 alts:["strict"],                                      needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"cognates"},
    {en:"strict (fem.)",                     fr:"stricte",                alts:["stricte"],                                     needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"cognates"},

    // ==================================================================
    // PERSONALITY ADJECTIVES — Les traits de personnalité
    // ==================================================================
    {en:"fun, amusing (masc.)",              fr:"amusant",                alts:["amusant"],                                     needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"personality"},
    {en:"fun, amusing (fem.)",               fr:"amusante",               alts:["amusante"],                                    needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"personality"},
    {en:"difficult",                         fr:"difficile",              alts:["difficile"],                                   needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"personality"},
    {en:"energetic",                         fr:"énergique",              alts:["énergique"],                                   needsHyphen:false, needsAccent:true,  gender:"both", guessGender:false, category:"personality"},
    {en:"interesting (masc.)",               fr:"intéressant",            alts:["intéressant"],                                 needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"personality"},
    {en:"interesting (fem.)",                fr:"intéressante",           alts:["intéressante"],                                needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"personality"},
    {en:"reasonable",                        fr:"raisonnable",            alts:["raisonnable"],                                 needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"personality"},
    {en:"resolute, determined (masc.)",      fr:"résolu",                 alts:["résolu"],                                      needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"personality"},
    {en:"resolute, determined (fem.)",       fr:"résolue",                alts:["résolue"],                                     needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"personality"},
    {en:"serious (masc.)",                   fr:"sérieux",                alts:["sérieux"],                                     needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"personality"},
    {en:"serious (fem.)",                    fr:"sérieuse",               alts:["sérieuse"],                                    needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"personality"},
    {en:"nice, friendly",                    fr:"sympathique",            alts:["sympathique"],                                 needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"personality"},

    // ==================================================================
    // POSSESSIVE ADJECTIVES — Les adjectifs possessifs
    // ==================================================================
    {en:"my (before masc. singular noun)",   fr:"mon",                    alts:["mon"],                                         needsHyphen:false, needsAccent:false, gender:"m",    guessGender:false, category:"possessives"},
    {en:"my (before fem. singular noun)",    fr:"ma",                     alts:["ma"],                                          needsHyphen:false, needsAccent:false, gender:"f",    guessGender:false, category:"possessives"},
    {en:"my (before plural noun)",           fr:"mes",                    alts:["mes"],                                         needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"possessives"},
    {en:"your, familiar (before masc. singular)", fr:"ton",               alts:["ton"],                                         needsHyphen:false, needsAccent:false, gender:"m",    guessGender:false, category:"possessives"},
    {en:"your, familiar (before fem. singular)",  fr:"ta",                alts:["ta"],                                          needsHyphen:false, needsAccent:false, gender:"f",    guessGender:false, category:"possessives"},
    {en:"your, familiar (before plural noun)",    fr:"tes",               alts:["tes"],                                         needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"possessives"},
    {en:"his, her, its (before masc. singular)",  fr:"son",               alts:["son"],                                         needsHyphen:false, needsAccent:false, gender:"m",    guessGender:false, category:"possessives"},
    {en:"his, her, its (before fem. singular)",   fr:"sa",                alts:["sa"],                                          needsHyphen:false, needsAccent:false, gender:"f",    guessGender:false, category:"possessives"},
    {en:"his, her, its (before plural noun)",     fr:"ses",               alts:["ses"],                                         needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"possessives"},
    {en:"our (before singular noun)",        fr:"notre",                  alts:["notre"],                                       needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"possessives"},
    {en:"our (before plural noun)",          fr:"nos",                    alts:["nos"],                                         needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"possessives"},
    {en:"your, formal (before singular noun)", fr:"votre",                alts:["votre"],                                       needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"possessives"},
    {en:"your, formal (before plural noun)", fr:"vos",                    alts:["vos"],                                         needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"possessives"},
    {en:"their (before singular noun)",      fr:"leur",                   alts:["leur"],                                        needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"possessives"},
    {en:"their (before plural noun)",        fr:"leurs",                  alts:["leurs"],                                       needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"possessives"},

    // ==================================================================
    // POSSESSION WITH DE — La possession avec « de » (Grammaire 1.6)
    // ==================================================================
    {en:"Bernard's sister",                  fr:"la sœur de Bernard",     alts:["la sœur de Bernard"],                          needsHyphen:false, needsAccent:false, gender:"both", category:"possession"},
    {en:"the teacher's books (de + le = du)", fr:"les livres du professeur", alts:["les livres du professeur"],                 needsHyphen:false, needsAccent:false, gender:"both", category:"possession"},
    {en:"the children's bicycle (de + les = des)", fr:"la bicyclette des enfants", alts:["la bicyclette des enfants"],          needsHyphen:false, needsAccent:false, gender:"both", category:"possession"},

    // ==================================================================
    // LEISURE ACTIVITIES — Activités favorites (infinitive phrases)
    // ==================================================================
    {en:"to go to the movies",               fr:"aller au cinéma",        alts:["aller au cinéma"],                             needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to go to the beach",                fr:"aller à la plage",       alts:["aller à la plage"],                            needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to go to the mountains",            fr:"aller à la montagne",    alts:["aller à la montagne"],                         needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to blog on the internet",           fr:"bloguer sur Internet",   alts:["bloguer sur Internet"],                        needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to sing in the shower",             fr:"chanter sous la douche", alts:["chanter sous la douche"],                      needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to drive a car",                    fr:"conduire une voiture",   alts:["conduire une voiture"],                        needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to have dinner at a restaurant",    fr:"dîner au restaurant",    alts:["dîner au restaurant"],                         needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to sleep late",                     fr:"dormir tard",            alts:["dormir tard"],                                 needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to listen to the radio",            fr:"écouter la radio",       alts:["écouter la radio"],                            needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to go grocery shopping",            fr:"faire les courses",      alts:["faire les courses"],                           needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to go camping",                     fr:"faire du camping",       alts:["faire du camping"],                            needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to party",                          fr:"faire la fête",          alts:["faire la fête"],                               needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to take a walk",                    fr:"faire une promenade",    alts:["faire une promenade"],                         needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to go skiing",                      fr:"faire du ski",           alts:["faire du ski"],                                needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to work in the yard",               fr:"travailler dans le jardin", alts:["travailler dans le jardin"],                needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to invite friends over",            fr:"inviter des amis",       alts:["inviter des amis"],                            needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to play cards",                     fr:"jouer aux cartes",       alts:["jouer aux cartes"],                            needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to play pool",                      fr:"jouer au billard",       alts:["jouer au billard"],                            needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to play soccer",                    fr:"jouer au football",      alts:["jouer au football","jouer au foot"],           needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to play tennis",                    fr:"jouer au tennis",        alts:["jouer au tennis"],                             needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to play video games",               fr:"jouer aux jeux vidéo",   alts:["jouer aux jeux vidéo"],                        needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to read the newspaper",             fr:"lire le journal",        alts:["lire le journal"],                             needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to swim in the pool",               fr:"nager à la piscine",     alts:["nager à la piscine"],                          needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to talk on the phone",              fr:"parler au téléphone",    alts:["parler au téléphone"],                         needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to send texts",                     fr:"envoyer des textos",     alts:["envoyer des textos"],                          needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to spend the evening together",     fr:"passer la soirée ensemble", alts:["passer la soirée ensemble"],                needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to watch television",               fr:"regarder la télévision", alts:["regarder la télévision","regarder la télé"],   needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to stay home",                      fr:"rester à la maison",     alts:["rester à la maison"],                          needsHyphen:false, needsAccent:true,  gender:"both", category:"activities"},
    {en:"to go out with friends",            fr:"sortir avec des amis",   alts:["sortir avec des amis"],                        needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},
    {en:"to travel",                         fr:"voyager",                alts:["voyager"],                                     needsHyphen:false, needsAccent:false, gender:"both", category:"activities"},

    // ==================================================================
    // ER VERBS — Les verbes en -er (infinitives)
    // ==================================================================
    {en:"to sing",                           fr:"chanter",                alts:["chanter"],                                     needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to look for, to go get",            fr:"chercher",               alts:["chercher"],                                    needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to dance",                          fr:"danser",                 alts:["danser"],                                      needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to eat lunch",                      fr:"déjeuner",               alts:["déjeuner"],                                    needsHyphen:false, needsAccent:true,  gender:"both", category:"er_verbs"},
    {en:"to draw",                           fr:"dessiner",               alts:["dessiner"],                                    needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to eat dinner",                     fr:"dîner",                  alts:["dîner"],                                       needsHyphen:false, needsAccent:true,  gender:"both", category:"er_verbs"},
    {en:"to give",                           fr:"donner",                 alts:["donner"],                                      needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to listen to",                      fr:"écouter",                alts:["écouter"],                                     needsHyphen:false, needsAccent:true,  gender:"both", category:"er_verbs"},
    {en:"to invite",                         fr:"inviter",                alts:["inviter"],                                     needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to play",                           fr:"jouer",                  alts:["jouer"],                                       needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to eat",                            fr:"manger",                 alts:["manger"],                                      needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to swim",                           fr:"nager",                  alts:["nager"],                                       needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to talk, to speak",                 fr:"parler",                 alts:["parler"],                                      needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to watch, to look at",              fr:"regarder",               alts:["regarder"],                                    needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to meet",                           fr:"rencontrer",             alts:["rencontrer"],                                  needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to return, to come back",           fr:"rentrer",                alts:["rentrer"],                                     needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to stay",                           fr:"rester",                 alts:["rester"],                                      needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to laugh, to have fun",             fr:"rigoler",                alts:["rigoler"],                                     needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to cook",                           fr:"cuisiner",               alts:["cuisiner"],                                    needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to work",                           fr:"travailler",             alts:["travailler"],                                  needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to live (somewhere)",               fr:"habiter",                alts:["habiter"],                                     needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to buy",                            fr:"acheter",                alts:["acheter"],                                     needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to begin, to start",                fr:"commencer",              alts:["commencer"],                                   needsHyphen:false, needsAccent:false, gender:"both", category:"er_verbs"},
    {en:"to prefer",                         fr:"préférer",               alts:["préférer"],                                    needsHyphen:false, needsAccent:true,  gender:"both", category:"er_verbs"},

    // ==================================================================
    // EXPRESSING PREFERENCE — Aimer, adorer, détester
    // ==================================================================
    {en:"What do you like to do?",           fr:"Qu'est-ce que tu aimes faire ?", alts:["Qu'est-ce que tu aimes faire","Qu'est-ce que tu aimes faire ?"], needsHyphen:false, needsAccent:false, gender:"both", category:"preference"},
    {en:"I love (it).",                      fr:"J'adore.",               alts:["J'adore","J'adore."],                          needsHyphen:false, needsAccent:false, gender:"both", category:"preference"},
    {en:"I like (it).",                      fr:"J'aime.",                alts:["J'aime","J'aime."],                            needsHyphen:false, needsAccent:false, gender:"both", category:"preference"},
    {en:"I prefer (it), I like it better.",  fr:"J'aime mieux.",          alts:["J'aime mieux","J'aime mieux."],                needsHyphen:false, needsAccent:false, gender:"both", category:"preference"},
    {en:"I really dislike (it).",            fr:"J'ai horreur de.",       alts:["J'ai horreur de","J'ai horreur de."],          needsHyphen:false, needsAccent:false, gender:"both", category:"preference"},
    {en:"We like (an activity).",            fr:"Nous aimons.",           alts:["Nous aimons","Nous aimons."],                  needsHyphen:false, needsAccent:false, gender:"both", category:"preference"},

    // ==================================================================
    // VERB VENIR — Conjugation
    // ==================================================================
    {en:"to come (infinitive)",              fr:"venir",                  alts:["venir"],                                       needsHyphen:false, needsAccent:false, gender:"both", category:"venir"},
    {en:"I come",                            fr:"je viens",               alts:["je viens"],                                    needsHyphen:false, needsAccent:false, gender:"both", category:"venir"},
    {en:"you come (familiar)",               fr:"tu viens",               alts:["tu viens"],                                    needsHyphen:false, needsAccent:false, gender:"both", category:"venir"},
    {en:"he comes",                          fr:"il vient",               alts:["il vient"],                                    needsHyphen:false, needsAccent:false, gender:"m",    category:"venir"},
    {en:"she comes",                         fr:"elle vient",             alts:["elle vient"],                                  needsHyphen:false, needsAccent:false, gender:"f",    category:"venir"},
    {en:"one comes (impersonal)",            fr:"on vient",               alts:["on vient"],                                    needsHyphen:false, needsAccent:false, gender:"both", category:"venir"},
    {en:"we come",                           fr:"nous venons",            alts:["nous venons"],                                 needsHyphen:false, needsAccent:false, gender:"both", category:"venir"},
    {en:"you come (formal or plural)",       fr:"vous venez",             alts:["vous venez"],                                  needsHyphen:false, needsAccent:false, gender:"both", category:"venir"},
    {en:"they come (masc. plural)",          fr:"ils viennent",           alts:["ils viennent"],                                needsHyphen:false, needsAccent:false, gender:"m",    category:"venir"},
    {en:"they come (fem. plural)",           fr:"elles viennent",         alts:["elles viennent"],                              needsHyphen:false, needsAccent:false, gender:"f",    category:"venir"},

    // ==================================================================
    // COUNTRIES & NATIONALITIES — Les pays et les nationalités
    // ==================================================================
    {en:"Algeria",                           fr:"l'Algérie",              alts:["l'Algérie"],                                   needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"countries"},
    {en:"Algerian (masc.)",                  fr:"algérien",               alts:["algérien"],                                    needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"countries"},
    {en:"Algerian (fem.)",                   fr:"algérienne",             alts:["algérienne"],                                  needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"countries"},
    {en:"Germany",                           fr:"l'Allemagne",            alts:["l'Allemagne"],                                 needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"German (masc.)",                    fr:"allemand",               alts:["allemand"],                                    needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"countries"},
    {en:"German (fem.)",                     fr:"allemande",              alts:["allemande"],                                   needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"Belgium",                           fr:"la Belgique",            alts:["la Belgique"],                                 needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"Belgian",                           fr:"belge",                  alts:["belge"],                                       needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"countries"},
    {en:"Canada",                            fr:"le Canada",              alts:["le Canada"],                                   needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"countries"},
    {en:"Canadian (masc.)",                  fr:"canadien",               alts:["canadien"],                                    needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"countries"},
    {en:"Canadian (fem.)",                   fr:"canadienne",             alts:["canadienne"],                                  needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"China",                             fr:"la Chine",               alts:["la Chine"],                                    needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"Chinese (masc.)",                   fr:"chinois",                alts:["chinois"],                                     needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"countries"},
    {en:"Chinese (fem.)",                    fr:"chinoise",               alts:["chinoise"],                                    needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"Spain",                             fr:"l'Espagne",              alts:["l'Espagne"],                                   needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"Spanish (masc.)",                   fr:"espagnol",               alts:["espagnol"],                                    needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"countries"},
    {en:"Spanish (fem.)",                    fr:"espagnole",              alts:["espagnole"],                                   needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"the United States",                 fr:"les États-Unis",         alts:["les États-Unis"],                              needsHyphen:true,  needsAccent:true,  gender:"m", guessGender:false, category:"countries"},
    {en:"American (masc.)",                  fr:"américain",              alts:["américain"],                                   needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"countries"},
    {en:"American (fem.)",                   fr:"américaine",             alts:["américaine"],                                  needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"countries"},
    {en:"France",                            fr:"la France",              alts:["la France"],                                   needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"French (masc.)",                    fr:"français",               alts:["français"],                                    needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"countries"},
    {en:"French (fem.)",                     fr:"française",              alts:["française"],                                   needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"countries"},
    {en:"Japan",                             fr:"le Japon",               alts:["le Japon"],                                    needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"countries"},
    {en:"Japanese (masc.)",                  fr:"japonais",               alts:["japonais"],                                    needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"countries"},
    {en:"Japanese (fem.)",                   fr:"japonaise",              alts:["japonaise"],                                   needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"Quebec",                            fr:"le Québec",              alts:["le Québec"],                                   needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"countries"},
    {en:"Quebecois (masc.)",                 fr:"québécois",              alts:["québécois"],                                   needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"countries"},
    {en:"Quebecois (fem.)",                  fr:"québécoise",             alts:["québécoise"],                                  needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"countries"},
    {en:"Senegal",                           fr:"le Sénégal",             alts:["le Sénégal"],                                  needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"countries"},
    {en:"Senegalese (masc.)",                fr:"sénégalais",             alts:["sénégalais"],                                  needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"countries"},
    {en:"Senegalese (fem.)",                 fr:"sénégalaise",            alts:["sénégalaise"],                                 needsHyphen:false, needsAccent:true,  gender:"f", guessGender:false, category:"countries"},
    {en:"Switzerland",                       fr:"la Suisse",              alts:["la Suisse"],                                   needsHyphen:false, needsAccent:false, gender:"f", guessGender:false, category:"countries"},
    {en:"Swiss",                             fr:"suisse",                 alts:["suisse"],                                      needsHyphen:false, needsAccent:false, gender:"both", guessGender:false, category:"countries"},

    // ==================================================================
    // LANGUAGES — Les langues
    // ==================================================================
    {en:"Arabic (the language)",             fr:"l'arabe",                alts:["l'arabe"],                                     needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"languages"},
    {en:"German (the language)",             fr:"l'allemand",             alts:["l'allemand"],                                  needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"languages"},
    {en:"English (the language)",            fr:"l'anglais",              alts:["l'anglais"],                                   needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"languages"},
    {en:"Chinese (the language)",            fr:"le chinois",             alts:["le chinois"],                                  needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"languages"},
    {en:"Spanish (the language)",            fr:"l'espagnol",             alts:["l'espagnol"],                                  needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"languages"},
    {en:"French (the language)",             fr:"le français",            alts:["le français"],                                 needsHyphen:false, needsAccent:true,  gender:"m", guessGender:false, category:"languages"},
    {en:"Japanese (the language)",           fr:"le japonais",            alts:["le japonais"],                                 needsHyphen:false, needsAccent:false, gender:"m", guessGender:false, category:"languages"},
    {en:"They speak English.",               fr:"Ils parlent anglais.",   alts:["Ils parlent anglais","Ils parlent anglais."],  needsHyphen:false, needsAccent:false, gender:"both", category:"languages"},
    {en:"They speak French.",                fr:"Ils parlent français.",  alts:["Ils parlent français","Ils parlent français."], needsHyphen:false, needsAccent:true,  gender:"both", category:"languages"},
    {en:"They speak Chinese.",               fr:"Ils parlent chinois.",   alts:["Ils parlent chinois","Ils parlent chinois."],  needsHyphen:false, needsAccent:false, gender:"both", category:"languages"},
    {en:"They speak Japanese.",              fr:"Ils parlent japonais.",  alts:["Ils parlent japonais","Ils parlent japonais."], needsHyphen:false, needsAccent:false, gender:"both", category:"languages"},
    {en:"They speak Spanish.",               fr:"Ils parlent espagnol.",  alts:["Ils parlent espagnol","Ils parlent espagnol."], needsHyphen:false, needsAccent:false, gender:"both", category:"languages"},

    // ==================================================================
    // PREPOSITIONS WITH PLACES — venir de / habiter à + pays
    // ==================================================================
    {en:"I come from France. (feminine country)",          fr:"Je viens de France.",      alts:["Je viens de France","Je viens de France."],     needsHyphen:false, needsAccent:false, gender:"both", category:"prepositions"},
    {en:"I come from Japan. (masc. country)",               fr:"Je viens du Japon.",       alts:["Je viens du Japon","Je viens du Japon."],       needsHyphen:false, needsAccent:false, gender:"both", category:"prepositions"},
    {en:"I come from Iran. (country starting with a vowel)", fr:"Je viens d'Iran.",        alts:["Je viens d'Iran","Je viens d'Iran."],           needsHyphen:false, needsAccent:false, gender:"both", category:"prepositions"},
    {en:"I come from the Philippines. (plural country)",    fr:"Je viens des Philippines.", alts:["Je viens des Philippines","Je viens des Philippines."], needsHyphen:false, needsAccent:false, gender:"both", category:"prepositions"},
    {en:"I live in Portugal. (masc. country)",              fr:"J'habite au Portugal.",    alts:["J'habite au Portugal","J'habite au Portugal."], needsHyphen:false, needsAccent:false, gender:"both", category:"prepositions"},
    {en:"I live in France. (feminine country)",             fr:"J'habite en France.",      alts:["J'habite en France","J'habite en France."],     needsHyphen:false, needsAccent:false, gender:"both", category:"prepositions"},
    {en:"I live in Iran. (country starting with a vowel)",  fr:"J'habite en Iran.",        alts:["J'habite en Iran","J'habite en Iran."],         needsHyphen:false, needsAccent:false, gender:"both", category:"prepositions"},
    {en:"I go to the United States. (plural country)",      fr:"Je vais aux États-Unis.",  alts:["Je vais aux États-Unis","Je vais aux États-Unis."], needsHyphen:true, needsAccent:true, gender:"both", category:"prepositions"},
    {en:"He comes from Canada.",                            fr:"Il vient du Canada.",      alts:["Il vient du Canada","Il vient du Canada."],     needsHyphen:false, needsAccent:false, gender:"m", category:"prepositions"},
    {en:"She comes from Canada.",                           fr:"Elle vient du Canada.",    alts:["Elle vient du Canada","Elle vient du Canada."], needsHyphen:false, needsAccent:false, gender:"f", category:"prepositions"},
    {en:"He comes from China.",                             fr:"Il vient de Chine.",       alts:["Il vient de Chine","Il vient de Chine."],       needsHyphen:false, needsAccent:false, gender:"m", category:"prepositions"},
    {en:"She comes from China.",                            fr:"Elle vient de Chine.",     alts:["Elle vient de Chine","Elle vient de Chine."],   needsHyphen:false, needsAccent:false, gender:"f", category:"prepositions"},
    {en:"He comes from Japan.",                             fr:"Il vient du Japon.",       alts:["Il vient du Japon","Il vient du Japon."],       needsHyphen:false, needsAccent:false, gender:"m", category:"prepositions"},
    {en:"She comes from Japan.",                            fr:"Elle vient du Japon.",     alts:["Elle vient du Japon","Elle vient du Japon."],   needsHyphen:false, needsAccent:false, gender:"f", category:"prepositions"},
    {en:"He comes from France.",                            fr:"Il vient de France.",      alts:["Il vient de France","Il vient de France."],     needsHyphen:false, needsAccent:false, gender:"m", category:"prepositions"},
    {en:"She comes from France.",                           fr:"Elle vient de France.",    alts:["Elle vient de France","Elle vient de France."], needsHyphen:false, needsAccent:false, gender:"f", category:"prepositions"},
    {en:"He comes from Spain.",                             fr:"Il vient d'Espagne.",      alts:["Il vient d'Espagne","Il vient d'Espagne."],     needsHyphen:false, needsAccent:false, gender:"m", category:"prepositions"},
    {en:"She comes from Spain.",                            fr:"Elle vient d'Espagne.",    alts:["Elle vient d'Espagne","Elle vient d'Espagne."], needsHyphen:false, needsAccent:false, gender:"f", category:"prepositions"},
    {en:"He comes from the United States.",                 fr:"Il vient des États-Unis.", alts:["Il vient des États-Unis","Il vient des États-Unis."], needsHyphen:true, needsAccent:true, gender:"m", category:"prepositions"},
    {en:"She comes from the United States.",                fr:"Elle vient des États-Unis.", alts:["Elle vient des États-Unis","Elle vient des États-Unis."], needsHyphen:true, needsAccent:true, gender:"f", category:"prepositions"},

    // ==================================================================
    // NUMBERS — Les nombres (101 and above)
    // ==================================================================
    {en:"one hundred one (101)",             fr:"cent un",                alts:["cent un"],                                     needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"one hundred two (102)",             fr:"cent deux",              alts:["cent deux"],                                   needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"two hundred (200)",                 fr:"deux cents",             alts:["deux cents"],                                  needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"two hundred one (201)",             fr:"deux cent un",           alts:["deux cent un"],                                needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"three hundred (300)",               fr:"trois cents",            alts:["trois cents"],                                 needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"one thousand (1 000)",              fr:"mille",                  alts:["mille"],                                       needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"ten thousand (10 000)",             fr:"dix mille",              alts:["dix mille"],                                   needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"one hundred thousand (100 000)",    fr:"cent mille",             alts:["cent mille"],                                  needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"one hundred fifty thousand (150 000)", fr:"cent cinquante mille", alts:["cent cinquante mille"],                       needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"one million (1 000 000)",           fr:"un million",             alts:["un million"],                                  needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"two million (2 000 000)",           fr:"deux millions",          alts:["deux millions"],                               needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"one billion (1 000 000 000)",       fr:"un milliard",            alts:["un milliard"],                                 needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},
    {en:"two billion (2 000 000 000)",       fr:"deux milliards",         alts:["deux milliards"],                              needsHyphen:false, needsAccent:false, gender:"both", category:"numbers"},

    // ==================================================================
    // DATES & AGE — Les dates et l'âge
    // ==================================================================
    {en:"It is the 30th of September.",      fr:"C'est le 30 septembre.", alts:["C'est le 30 septembre","C'est le 30 septembre."], needsHyphen:false, needsAccent:false, gender:"both", category:"dates"},
    {en:"It is the 1st of November.",        fr:"Nous sommes le 1er novembre.", alts:["Nous sommes le 1er novembre","Nous sommes le 1er novembre."], needsHyphen:false, needsAccent:false, gender:"both", category:"dates"},
    {en:"I am nineteen years old.",          fr:"J'ai dix-neuf ans.",     alts:["J'ai dix-neuf ans","J'ai dix-neuf ans."],      needsHyphen:true,  needsAccent:false, gender:"both", category:"dates"},
    {en:"My birthday is October 15th.",      fr:"Mon anniversaire est le 15 octobre.", alts:["Mon anniversaire est le 15 octobre","Mon anniversaire est le 15 octobre."], needsHyphen:false, needsAccent:false, gender:"both", category:"dates"},
    {en:"I was born in 1998. (masc.)",       fr:"Je suis né en 1998.",    alts:["Je suis né en 1998","Je suis né en 1998."],    needsHyphen:false, needsAccent:true,  gender:"m", category:"dates"},
    {en:"I was born in 1998. (fem.)",        fr:"Je suis née en 1998.",   alts:["Je suis née en 1998","Je suis née en 1998."],  needsHyphen:false, needsAccent:true,  gender:"f", category:"dates"},
    {en:"1995 (standard French form)",       fr:"mille neuf cent quatre-vingt-quinze", alts:["mille neuf cent quatre-vingt-quinze"], needsHyphen:true, needsAccent:false, gender:"both", category:"dates"},
    {en:"1995 (alternative form)",           fr:"dix-neuf cent quatre-vingt-quinze", alts:["dix-neuf cent quatre-vingt-quinze"], needsHyphen:true, needsAccent:false, gender:"both", category:"dates"},

    // ==================================================================
    // PERSONAL INFO QUESTIONS — Renseignements personnels
    // ==================================================================
    {en:"What is Sarah's phone number?",     fr:"Quel est le numéro de téléphone de Sarah ?", alts:["Quel est le numéro de téléphone de Sarah","Quel est le numéro de téléphone de Sarah ?"], needsHyphen:false, needsAccent:true, gender:"both", category:"personal_info"},
    {en:"Where does Adrienne live?",         fr:"Où habite Adrienne ?",   alts:["Où habite Adrienne","Où habite Adrienne ?"],   needsHyphen:false, needsAccent:true,  gender:"both", category:"personal_info"},
    {en:"What is Raoul's address?",          fr:"Quelle est l'adresse de Raoul ?", alts:["Quelle est l'adresse de Raoul","Quelle est l'adresse de Raoul ?"], needsHyphen:false, needsAccent:false, gender:"both", category:"personal_info"},
    {en:"What city are you from?",           fr:"De quelle ville viens-tu ?", alts:["De quelle ville viens-tu","De quelle ville viens-tu ?"], needsHyphen:true, needsAccent:false, gender:"both", category:"personal_info"},
    {en:"What is your email address?",       fr:"Quelle est ton adresse mail ?", alts:["Quelle est ton adresse mail","Quelle est ton adresse mail ?"], needsHyphen:false, needsAccent:false, gender:"both", category:"personal_info"},
    {en:"What is your phone number?",        fr:"Quel est ton numéro de téléphone ?", alts:["Quel est ton numéro de téléphone","Quel est ton numéro de téléphone ?"], needsHyphen:false, needsAccent:true, gender:"both", category:"personal_info"},
    {en:"What is your address?",             fr:"Quelle est ton adresse ?", alts:["Quelle est ton adresse","Quelle est ton adresse ?"], needsHyphen:false, needsAccent:false, gender:"both", category:"personal_info"},
    {en:"When and where were you born? (masc.)", fr:"Quand et où est-ce que tu es né ?", alts:["Quand et où est-ce que tu es né","Quand et où est-ce que tu es né ?"], needsHyphen:true, needsAccent:true, gender:"m", category:"personal_info"},
    {en:"When and where were you born? (fem.)",  fr:"Quand et où est-ce que tu es née ?", alts:["Quand et où est-ce que tu es née","Quand et où est-ce que tu es née ?"], needsHyphen:true, needsAccent:true, gender:"f", category:"personal_info"},
    {en:"What nationality is she?",          fr:"De quelle nationalité est-elle ?", alts:["De quelle nationalité est-elle","De quelle nationalité est-elle ?"], needsHyphen:true, needsAccent:true, gender:"both", category:"personal_info"},
    {en:"What language does she speak?",     fr:"Quelle langue est-ce qu'elle parle ?", alts:["Quelle langue est-ce qu'elle parle","Quelle langue est-ce qu'elle parle ?"], needsHyphen:true, needsAccent:false, gender:"both", category:"personal_info"},
    {en:"Where do you come from?",           fr:"D'où viens-tu ?",        alts:["D'où viens-tu","D'où viens-tu ?"],             needsHyphen:true,  needsAccent:true,  gender:"both", category:"personal_info"},

    // ==================================================================
    // ORAL DESCRIPTION STRUCTURE — Présenter une personne
    // ==================================================================
    {en:"His name is (introducing a man)",   fr:"Il s'appelle",           alts:["Il s'appelle"],                                needsHyphen:true,  needsAccent:false, gender:"m", category:"oral_description"},
    {en:"Her name is (introducing a woman)", fr:"Elle s'appelle",         alts:["Elle s'appelle"],                              needsHyphen:true,  needsAccent:false, gender:"f", category:"oral_description"},
    {en:"He lives in",                       fr:"Il habite à",            alts:["Il habite à"],                                 needsHyphen:false, needsAccent:true,  gender:"m", category:"oral_description"},
    {en:"She lives in",                      fr:"Elle habite à",          alts:["Elle habite à"],                               needsHyphen:false, needsAccent:true,  gender:"f", category:"oral_description"},
    {en:"He is (a number of) years old.",    fr:"Il a ans.",              alts:["Il a ans","Il a ans."],                        needsHyphen:false, needsAccent:false, gender:"m", category:"oral_description"},
    {en:"She is (a number of) years old.",   fr:"Elle a ans.",            alts:["Elle a ans","Elle a ans."],                    needsHyphen:false, needsAccent:false, gender:"f", category:"oral_description"},
    {en:"He speaks",                         fr:"Il parle",               alts:["Il parle"],                                    needsHyphen:false, needsAccent:false, gender:"m", category:"oral_description"},
    {en:"She speaks",                        fr:"Elle parle",             alts:["Elle parle"],                                  needsHyphen:false, needsAccent:false, gender:"f", category:"oral_description"},
    {en:"He is (nationality)",               fr:"Il est",                 alts:["Il est"],                                      needsHyphen:false, needsAccent:false, gender:"m", category:"oral_description"},
    {en:"She is (nationality)",              fr:"Elle est",               alts:["Elle est"],                                    needsHyphen:false, needsAccent:false, gender:"f", category:"oral_description"},
  ],
  categoryLabels: {
    all:"Random",
    family:"Family",
    relationships:"Relationships",
    family_phrases:"Family questions",
    description:"Describing",
    cognates:"Cognate adjectives",
    personality:"Personality",
    possessives:"Possessive adjectives",
    possession:"Possession with « de »",
    activities:"Activities",
    er_verbs:"-ER verbs",
    preference:"Likes & preferences",
    venir:"Venir",
    countries:"Countries & nationalities",
    languages:"Languages",
    prepositions:"Prepositions with places",
    numbers:"Numbers",
    dates:"Dates & age",
    personal_info:"Personal info",
    oral_description:"Oral description"
  }
};
