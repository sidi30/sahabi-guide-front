/// Contenu détaillé par rituel du Hajj/Omra.
///
/// Chaque rituel possède un guide PROPRE selon 4 axes :
///  - [explanation]   : présentation / sens du rite.
///  - [importantSteps]: ce qu'il est important de faire (déroulé).
///  - [howTo]         : comment l'accomplir concrètement / variantes possibles.
///  - [security]      : sécurité (foule, santé, erreurs à éviter).
///  - [practicalTips] : repères pratiques (durée, conseils ciblés).
///
/// Indexé par l'`id` du rituel (cf. assets/data/rituals.json), ce qui évite la
/// fragilité d'un `switch` sur le nom traduit. Source : consensus sunnite
/// classique (manuels de Hajj). Contenu en français (langue par défaut de
/// l'app) ; la lecture vocale s'appuie sur ce texte.
///
/// TODO(refonte-genre) cf. docs/refonte-genre-rites.md — SOURCE DE VÉRITÉ N°2 :
/// prose française uniquement, NON filtrée par genre (elle contient des actes
/// explicitement masculins : Idtiba'/Raml, Halq/Taqsir) et une dispense menstrues
/// codée en dur. Elle ne sert plus qu'en repli quand le serveur ne renvoie aucune
/// étape, et n'est jamais affichée à un profil féminin (cf.
/// `RitualDetailSection._hidesStaticGuidance`). À SUPPRIMER une fois tous les
/// rites migrés en schemaVersion 2 côté serveur.
class RitualGuidance {
  final String explanation;
  final List<String> importantSteps;
  final List<String> howTo;
  final List<String> security;
  final Map<String, String> practicalTips;

  const RitualGuidance({
    required this.explanation,
    required this.importantSteps,
    required this.howTo,
    required this.security,
    required this.practicalTips,
  });

  /// Texte lu à voix haute (TTS) : enchaîne les sections distinctes.
  String toSpeech(String ritualName) {
    final b = StringBuffer()
      ..writeln('$ritualName.')
      ..writeln(explanation)
      ..writeln('Étapes importantes.');
    for (final s in importantSteps) {
      b.writeln('$s.');
    }
    b.writeln('Comment l\'accomplir.');
    for (final s in howTo) {
      b.writeln('$s.');
    }
    b.writeln('Sécurité.');
    for (final s in security) {
      b.writeln('$s.');
    }
    return b.toString();
  }
}

/// Guide détaillé pour chacun des 13 rites du Hajj (ids alignés sur
/// assets/data/rituals.json).
const Map<String, RitualGuidance> kRitualGuidance = {
  // 1. Ihram ----------------------------------------------------------------
  'ihram': RitualGuidance(
    explanation:
        "L'Ihram est l'état de sacralisation par lequel on entre en pèlerinage. "
        "Il commence au Meeqat (point de mise en Ihram) par l'intention (niyyah) "
        "et la Talbiyah, et impose un ensemble d'interdits jusqu'à la sortie de l'Ihram.",
    importantSteps: [
      "Se purifier : grandes ablutions (ghusl) recommandées, se parfumer le corps (avant l'Ihram, pas les vêtements).",
      "Revêtir les deux pièces blanches non cousues pour l'homme ; tenue couvrante normale pour la femme (sans niqab ni gants).",
      "Formuler l'intention au Meeqat selon le type choisi : Tamattu', Qiran ou Ifrad.",
      "Commencer la Talbiyah : « Labbayka Allahumma labbayk… » et la répéter abondamment.",
    ],
    howTo: [
      "Tamattu' (le plus courant) : Omra d'abord, sortie d'Ihram, puis nouvel Ihram pour le Hajj le 8 Dhul-Hijjah.",
      "Qiran : Omra et Hajj dans un même Ihram, sans sortir entre les deux (sacrifice obligatoire).",
      "Ifrad : Hajj seul, sans Omra liée (pas de sacrifice obligatoire).",
      "Si l'on craint un empêchement (maladie), poser une condition (ishtirat) lors de l'intention.",
    ],
    security: [
      "Ne pas appliquer de parfum sur les vêtements d'Ihram ni se couvrir la tête (homme).",
      "Éviter de se mettre en Ihram trop tôt pour ne pas prolonger inutilement les interdits.",
      "Protéger sa peau du soleil (ombre autorisée) et bien s'hydrater dès le départ.",
      "Femmes : le visage et les mains restent découverts ; couvrir le visage seulement en présence d'hommes étrangers, sans tissu collé.",
    ],
    practicalTips: {
      "Meeqat": "Mettre l'Ihram avant de franchir le Meeqat",
      "Interdits": "Pas de chasse, rapports, coupe de cheveux/ongles, dispute",
      "Talbiyah": "À répéter souvent jusqu'au début du Tawaf",
    },
  ),

  // 2. Tawaf ----------------------------------------------------------------
  'tawaf': RitualGuidance(
    explanation:
        "Le Tawaf consiste à tourner sept fois autour de la Kaaba dans le sens "
        "inverse des aiguilles d'une montre, en commençant et terminant chaque "
        "tour à la Pierre Noire (Hajar al-Aswad).",
    importantSteps: [
      "Être en état de pureté (wudu) avant de commencer.",
      "Débuter face à la Pierre Noire en disant « Bismillah, Allahu Akbar », paume tendue vers elle.",
      "Effectuer 7 tours complets, la Kaaba sur sa gauche.",
      "Pour l'homme : Idtiba' (épaule droite découverte) et Raml (marche rapide) lors des 3 premiers tours du Tawaf d'arrivée.",
      "Prier 2 rak'as derrière le Maqam Ibrahim après les 7 tours, puis boire de l'eau de Zamzam.",
    ],
    howTo: [
      "Toucher ou embrasser la Pierre Noire si possible SANS bousculer ; sinon, pointer la main vers elle à chaque tour.",
      "Toucher le coin yéménite (Rukn Yamani) de la main sans l'embrasser si on y accède ; sinon ne rien faire.",
      "Réciter librement Coran, invocations et dhikr ; entre les deux coins, dire la doua « Rabbana atina… ».",
      "En cas de forte affluence, faire le Tawaf à l'étage ou sur le toit reste valide.",
    ],
    security: [
      "Ne JAMAIS forcer vers la Pierre Noire dans la foule : risque d'écrasement et de piétinement.",
      "Garder ses affaires près de soi ; rester avec son groupe et fixer un point de ralliement.",
      "Boire régulièrement ; sortir du flux par les bords si l'on se sent mal, pas au centre.",
      "Personnes âgées / fragiles : utiliser un fauteuil roulant ou les niveaux supérieurs, moins denses.",
    ],
    practicalTips: {
      "Durée": "30 à 60 minutes selon l'affluence",
      "Pureté": "Le wudu est requis pendant tout le Tawaf",
      "Conseil": "Compter les tours pour ne pas se tromper",
    },
  ),

  // 3. Sa'i -----------------------------------------------------------------
  'sai': RitualGuidance(
    explanation:
        "Le Sa'i est la marche sept fois entre les collines de Safa et Marwa, "
        "en mémoire de Hajar cherchant de l'eau pour son fils Ismaël. Il se fait "
        "après le Tawaf.",
    importantSteps: [
      "Commencer à Safa en récitant le verset « Inna as-Safa wa al-Marwata… ».",
      "Monter légèrement sur Safa, se tourner vers la Kaaba et invoquer Allah, mains levées.",
      "Marcher vers Marwa : un aller (Safa→Marwa) compte pour 1, le retour pour 2, etc.",
      "Accomplir 7 trajets au total ; le 7e se termine à Marwa.",
    ],
    howTo: [
      "Entre les deux repères lumineux verts, les hommes accélèrent le pas (course légère) ; les femmes marchent normalement.",
      "Répéter invocations et dhikr librement à chaque montée.",
      "La pureté rituelle n'est pas obligatoire pour le Sa'i (recommandée).",
      "Fauteuil roulant possible sur la voie centrale dédiée en cas de fatigue.",
    ],
    security: [
      "Porter des chaussures confortables : le parcours fait environ 3,5 km cumulés.",
      "S'hydrater (points Zamzam le long du trajet) pour éviter le malaise.",
      "Ne pas courir réellement : la « course » se limite à la zone verte, pour éviter chutes et collisions.",
      "Tenir les enfants par la main ; convenir d'un point de rendez-vous à Safa ou Marwa.",
    ],
    practicalTips: {
      "Distance": "Environ 3,5 km au total",
      "Durée": "20 à 40 minutes",
      "Conseil": "Chaussures confortables, eau à portée",
    },
  ),

  // 4. Séjour à Mina (8 Dhul-Hijjah) ----------------------------------------
  'mina': RitualGuidance(
    explanation:
        "Le 8 Dhul-Hijjah (jour de la Tarwiyah), les pèlerins se rendent à Mina "
        "et y passent la journée et la nuit, accomplissant les cinq prières "
        "(Dhuhr à Fajr) raccourcies à l'heure, en préparation du jour d'Arafat.",
    importantSteps: [
      "Partir vers Mina le matin du 8 après s'être remis en Ihram (pour ceux en Tamattu').",
      "Y prier Dhuhr, Asr, Maghrib, Isha et Fajr ; raccourcir les prières de 4 rak'as à 2 sans les regrouper.",
      "Passer la nuit à Mina (sunna) et multiplier dhikr et invocations.",
    ],
    howTo: [
      "Le séjour à Mina le 8 est une sunna confirmée, pas un pilier : le manquer n'invalide pas le Hajj.",
      "Loger dans la tente assignée à son groupe et mémoriser son numéro de secteur.",
      "Préparer ses affaires pour Arafat (médicaments, eau, brumisateur) dès Mina.",
    ],
    security: [
      "Repérer immédiatement le numéro de sa tente et les sorties de secours.",
      "Ne pas cuisiner au gaz dans les tentes (risque d'incendie déjà survenu à Mina).",
      "Garder ses papiers et son bracelet d'identification du groupe sur soi.",
      "Climat très chaud : rester à l'ombre des tentes aux heures de pointe.",
    ],
    practicalTips: {
      "Quand": "Journée et nuit du 8 Dhul-Hijjah",
      "Prières": "Raccourcies (2 rak'as), à l'heure, non regroupées",
      "Statut": "Sunna (recommandé)",
    },
  ),

  // 5. Jour d'Arafat (9) ----------------------------------------------------
  'arafat': RitualGuidance(
    explanation:
        "Le Wuquf (station) à Arafat le 9 Dhul-Hijjah est LE pilier majeur du "
        "Hajj : « Le Hajj, c'est Arafat. » Y manquer invalide le pèlerinage. "
        "On s'y consacre à l'invocation du midi au coucher du soleil.",
    importantSteps: [
      "Arriver à Arafat dans la matinée et y rester jusqu'au coucher du soleil.",
      "Prier Dhuhr et Asr regroupés et raccourcis à l'heure de Dhuhr (à la mosquée Namira si possible).",
      "Consacrer l'après-midi à l'invocation tourné vers la Qibla, mains levées.",
      "Multiplier la meilleure invocation : « La ilaha illa Allah wahdahu la sharika lah… ».",
      "Ne partir qu'APRÈS le coucher du soleil, vers Muzdalifah.",
    ],
    howTo: [
      "S'assurer d'être dans les limites d'Arafat (panneaux) ; Jabal ar-Rahma n'est pas obligatoire.",
      "Une seule présence, même brève, entre midi et l'aube suivante suffit pour valider le pilier.",
      "Alterner invocation personnelle, demande de pardon (istighfar) et lecture du Coran.",
    ],
    security: [
      "Chaleur extrême : parasol, brumisateur, eau en abondance, sels de réhydratation.",
      "Repérer son bus et son numéro AVANT la dispersion du soir pour ne pas se perdre.",
      "Surveiller les signes de coup de chaleur (vertiges, arrêt de la sueur) et se mettre à l'ombre.",
      "Ne pas s'épuiser à monter Jabal ar-Rahma dans la foule : ce n'est pas requis.",
    ],
    practicalTips: {
      "Statut": "Pilier essentiel — l'oublier annule le Hajj",
      "Durée": "De midi au coucher du soleil",
      "Prières": "Dhuhr + Asr regroupées et raccourcies",
    },
  ),

  // 6. Muzdalifah -----------------------------------------------------------
  'muzdalifah': RitualGuidance(
    explanation:
        "Après le coucher du soleil à Arafat, on se rend à Muzdalifah pour y "
        "passer la nuit, y prier Maghrib et Isha regroupés, et y ramasser les "
        "cailloux de la lapidation.",
    importantSteps: [
      "Prier Maghrib (3) et Isha (2) regroupés à l'arrivée, avec un seul adhan et deux iqamas.",
      "Passer la nuit sur place jusqu'à l'aube (Fajr).",
      "Prier Fajr tôt puis invoquer près d'Al-Mash'ar al-Haram jusqu'aux lueurs du jour.",
      "Ramasser environ 49 à 70 cailloux (taille d'un pois) pour les jours de lapidation.",
    ],
    howTo: [
      "Les personnes faibles, femmes et enfants peuvent partir après la mi-nuit vers Mina (concession prophétique).",
      "Les cailloux peuvent aussi être ramassés à Mina : Muzdalifah n'est pas obligatoire pour cela.",
      "Dormir un peu est permis : la nuit à Muzdalifah est un repos avant Mina.",
    ],
    security: [
      "Sol en plein air : prévoir un tapis, de quoi se couvrir, la nuit peut être fraîche.",
      "Rester groupé : l'endroit est vaste, sombre et très peuplé.",
      "Ne pas ramasser de cailloux trop gros (interdit et dangereux pour autrui).",
      "Garder eau et médicaments ; toilettes très fréquentées, anticiper.",
    ],
    practicalTips: {
      "Prières": "Maghrib + Isha regroupées",
      "À faire": "Ramasser ~70 cailloux",
      "Concession": "Départ après mi-nuit pour les faibles",
    },
  ),

  // 7. Ramy (lapidation, jour de l'Aïd) -------------------------------------
  'ramy': RitualGuidance(
    explanation:
        "Le matin du 10 Dhul-Hijjah (jour de l'Aïd), on lapide la grande stèle "
        "(Jamrat al-Aqaba) avec sept cailloux, en signe de rejet de Satan, "
        "premier des rites de désacralisation.",
    importantSteps: [
      "Cesser la Talbiyah au début de la lapidation.",
      "Lancer 7 cailloux successivement sur Jamrat al-Aqaba, en disant « Allahu Akbar » à chaque jet.",
      "Viser le bassin de la stèle ; les cailloux doivent y tomber.",
      "Ce jour-là, seule la grande stèle est lapidée.",
    ],
    howTo: [
      "Lancer les cailloux un par un (pas en bloc) ; un jet groupé ne compte que pour un.",
      "Choisir les heures creuses (nuit, après-midi) en cas de forte foule.",
      "Déléguer la lapidation à un mandataire est permis pour les malades, femmes enceintes et personnes faibles.",
    ],
    security: [
      "Suivre le sens de circulation imposé ; ne jamais s'arrêter ni rebrousser chemin dans la foule (risque de bousculade mortelle).",
      "Lapider aux heures les moins denses si l'on est fragile.",
      "Ne pas se battre pour approcher : la distance de jet est suffisante.",
      "Tenir fermement les enfants ou les confier à quelqu'un hors de la cohue.",
    ],
    practicalTips: {
      "Quand": "Matin du 10 (et heures creuses)",
      "Cailloux": "7 sur la grande stèle",
      "Délégation": "Permise pour les faibles/malades",
    },
  ),

  // 8. Hady (sacrifice) -----------------------------------------------------
  'hady': RitualGuidance(
    explanation:
        "Le Hady est le sacrifice offert le jour de l'Aïd, obligatoire pour les "
        "pèlerins en Tamattu' et Qiran. Sa viande est destinée à la consommation "
        "et à l'aumône.",
    importantSteps: [
      "Acquitter le sacrifice après la lapidation de la grande stèle (idéalement).",
      "Une bête menue (mouton/chèvre) par personne, ou 1/7 de bovin/chameau.",
      "Mentionner le nom d'Allah au moment de l'égorgement.",
    ],
    howTo: [
      "Le plus simple et sûr : payer un coupon (banque islamique / Adahi) ; l'abattage est géré en abattoir agréé.",
      "On peut aussi sacrifier soi-même si l'on dispose d'un accès légal à un abattoir.",
      "Qui n'en a pas les moyens (Tamattu'/Qiran) jeûne 3 jours pendant le Hajj et 7 au retour.",
    ],
    security: [
      "Passer par les circuits officiels (coupons) : éviter les abattages sauvages, interdits et insalubres.",
      "Conserver le justificatif du coupon de sacrifice.",
      "Ne pas se rendre soi-même aux abattoirs bondés sans nécessité.",
    ],
    practicalTips: {
      "Pour qui": "Obligatoire en Tamattu' et Qiran",
      "Le plus simple": "Coupon de sacrifice (Adahi)",
      "Alternative": "Jeûne 3 + 7 jours si sans moyens",
    },
  ),

  // 9. Halq / Taqsir --------------------------------------------------------
  'halq': RitualGuidance(
    explanation:
        "Après le sacrifice, l'homme se rase la tête (Halq) ou se coupe les "
        "cheveux (Taqsir) ; la femme coupe l'équivalent d'une phalange. C'est "
        "ce qui parachève la première désacralisation.",
    importantSteps: [
      "Pour l'homme : raser entièrement la tête (Halq, plus méritoire) ou raccourcir tous les cheveux (Taqsir).",
      "Pour la femme : couper l'équivalent d'une phalange (≈ 2-3 cm) sur l'ensemble des cheveux.",
      "Après cela survient le premier dessacralisation (Tahallul al-Awwal) : la plupart des interdits tombent, sauf les rapports conjugaux.",
    ],
    howTo: [
      "Le Halq se fait en commençant par le côté droit de la tête.",
      "Choisir un salon/barbier agréé et hygiénique.",
      "Le rasage clôture l'ordre recommandé du jour de l'Aïd : lapidation → sacrifice → rasage → Tawaf al-Ifada (l'ordre peut varier sans pénalité).",
    ],
    security: [
      "Exiger une lame NEUVE et à usage unique : risque réel de transmission (hépatites, VIH) avec lames partagées.",
      "Préférer un coiffeur officiel à un rasage de rue improvisé.",
      "Protéger le cuir chevelu rasé du soleil (casquette/ombre).",
    ],
    practicalTips: {
      "Homme": "Halq (rasage) ou Taqsir (raccourcir)",
      "Femme": "Couper ~ une phalange",
      "Hygiène": "Lame neuve à usage unique impérative",
    },
  ),

  // 10. Tawaf al-Ifada ------------------------------------------------------
  'tawaf_ifada': RitualGuidance(
    explanation:
        "Le Tawaf al-Ifada (ou Tawaf az-Ziyara) est un PILIER du Hajj : sept "
        "tours autour de la Kaaba accomplis après la descente d'Arafat, "
        "généralement le jour de l'Aïd.",
    importantSteps: [
      "Se rendre à la Mosquée sacrée après la lapidation, le sacrifice et le rasage.",
      "Accomplir 7 tours autour de la Kaaba en état de pureté.",
      "Prier 2 rak'as derrière le Maqam Ibrahim.",
      "Ce Tawaf accompli (avec le Sa'i si requis) parachève la seconde désacralisation : tout redevient licite.",
    ],
    howTo: [
      "Il peut être différé jusqu'à la fin des jours de Mina si la foule est trop dense.",
      "Pas de Raml ni d'Idtiba' ici (ils sont propres au Tawaf d'arrivée).",
      "Le faire aux heures creuses (nuit) réduit fortement l'attente.",
    ],
    security: [
      "Forte affluence le jour de l'Aïd : privilégier la nuit ou les étages.",
      "Rester avec son groupe ; fixer un point de retrouvailles hors de l'enceinte.",
      "S'hydrater et faire des pauses si l'on enchaîne plusieurs rites le même jour.",
    ],
    practicalTips: {
      "Statut": "Pilier du Hajj — indispensable",
      "Quand": "À partir du jour de l'Aïd",
      "Conseil": "De nuit pour éviter la foule",
    },
  ),

  // 11. Sa'i al-Ifada -------------------------------------------------------
  'sai_ifada': RitualGuidance(
    explanation:
        "Le Sa'i du Hajj suit le Tawaf al-Ifada. Il est obligatoire pour les "
        "pèlerins en Tamattu', et pour ceux en Ifrad/Qiran qui ne l'avaient pas "
        "fait avec le Tawaf d'arrivée.",
    importantSteps: [
      "Effectuer 7 trajets entre Safa et Marwa après le Tawaf al-Ifada.",
      "Commencer à Safa, terminer à Marwa.",
      "Invoquer Allah à chaque montée comme lors du premier Sa'i.",
    ],
    howTo: [
      "Pèlerins en Tamattu' : ce Sa'i est requis (le premier comptait pour l'Omra).",
      "Pèlerins en Qiran/Ifrad ayant déjà fait le Sa'i après le Tawaf d'arrivée : pas besoin de le refaire.",
      "Peut être enchaîné juste après le Tawaf al-Ifada ou différé avec lui.",
    ],
    security: [
      "Même vigilance que pour le premier Sa'i : hydratation, chaussures, point de ralliement.",
      "Voie centrale et fauteuils roulants disponibles pour les personnes fatiguées.",
      "Éviter d'enchaîner trop de rites sans repos : risque d'épuisement.",
    ],
    practicalTips: {
      "Pour qui": "Obligatoire surtout en Tamattu'",
      "Distance": "Environ 3,5 km",
      "Conseil": "Possible juste après le Tawaf al-Ifada",
    },
  ),

  // 12. Jours de Mina (Tashriq 11-13) ---------------------------------------
  'mina_days': RitualGuidance(
    explanation:
        "Les jours de Tashriq (11, 12 et éventuellement 13 Dhul-Hijjah) se "
        "passent à Mina : on y dort la nuit et on lapide chaque jour les trois "
        "stèles (petite, moyenne, grande).",
    importantSteps: [
      "Passer les nuits à Mina (obligatoire selon la majorité).",
      "Chaque après-midi, lapider les 3 stèles dans l'ordre : petite (Sughra), moyenne (Wusta), puis grande (Aqaba), 7 cailloux chacune.",
      "Après la petite et la moyenne stèle, s'écarter pour invoquer longuement, face à la Qibla.",
      "Dire « Allahu Akbar » à chaque caillou (49 cailloux sur 11+12, 70 si l'on reste le 13).",
    ],
    howTo: [
      "Ta'ajjul : on peut écourter et quitter Mina le 12 avant le coucher du soleil, après la lapidation.",
      "Qui ne part pas le 12 avant le maghrib doit rester pour lapider aussi le 13.",
      "Délégation de la lapidation permise pour les malades et les faibles.",
      "La lapidation est valable du midi jusqu'à la nuit ; choisir les heures creuses.",
    ],
    security: [
      "Respecter le sens de marche imposé vers les stèles ; ne jamais s'arrêter dans le flux.",
      "Lapider aux heures les moins denses si l'on est fragile (le créneau de midi est le plus dangereux).",
      "Bien s'hydrater et se protéger du soleil entre les tentes.",
      "Mémoriser l'itinéraire tente ↔ stèles ; rester avec son groupe.",
    ],
    practicalTips: {
      "Quand": "11, 12 (et 13) Dhul-Hijjah",
      "Lapidation": "3 stèles × 7 cailloux/jour, dans l'ordre",
      "Ta'ajjul": "Départ permis le 12 avant le maghrib",
    },
  ),

  // 13. Tawaf al-Wida (adieu) -----------------------------------------------
  'tawaf_wida': RitualGuidance(
    explanation:
        "Le Tawaf al-Wida (adieu) est le dernier rite : sept tours autour de la "
        "Kaaba juste avant de quitter La Mecque, afin que le dernier acte du "
        "pèlerin soit auprès de la Maison sacrée.",
    importantSteps: [
      "L'accomplir en TOUT DERNIER, après avoir terminé toutes ses affaires à La Mecque.",
      "Faire 7 tours autour de la Kaaba.",
      "Prier 2 rak'as derrière le Maqam Ibrahim, puis quitter directement.",
    ],
    howTo: [
      "Obligatoire pour la majorité des pèlerins ; son oubli impose une compensation (sacrifice) selon plusieurs écoles.",
      "Les femmes en menstrues ou en lochies en sont DISPENSÉES et ne le remplacent pas.",
      "Pas de Sa'i ni de Raml ici : un simple Tawaf.",
    ],
    security: [
      "Le programmer au moment où l'on part réellement, pour ne pas refaire d'achats après.",
      "Anticiper l'horaire du bus/vol : l'enceinte peut être très dense.",
      "Garder ses bagages surveillés et son groupe en vue jusqu'au départ.",
    ],
    practicalTips: {
      "Statut": "Dernier rite avant le départ",
      "Dispense": "Femmes en menstrues exemptées",
      "Conseil": "Le faire juste avant de quitter La Mecque",
    },
  ),
};

/// Récupère le guide d'un rituel par son id, avec repli par mots-clés du nom.
///
/// Les sources réelles (rituals_seed.json) utilisent des UUID comme id et des
/// noms composés (« Tawaf Al-Ifadah », « Jours de Tashreeq »…). On matche donc
/// par mots-clés du nom, du PLUS SPÉCIFIQUE au plus générique : sinon le mot
/// « tawaf » capterait l'Ifada et le Wada par erreur, et « mina » capterait les
/// jours de Tashreeq.
RitualGuidance? guidanceFor(String id, String name) {
  final direct = kRitualGuidance[id];
  if (direct != null) return direct;
  final n = name.toLowerCase();

  // --- Composés Tawaf (avant le générique 'tawaf') ---
  if (n.contains('wada') || n.contains('wida') || n.contains('adieu')) {
    return kRitualGuidance['tawaf_wida'];
  }
  if (n.contains('ifada') || n.contains('ifadah') || n.contains('ziyara')) {
    return kRitualGuidance['tawaf_ifada'];
  }

  // --- Jours / séjours à Mina (avant le générique 'mina') ---
  if (n.contains('tashr') || n.contains('tashreeq') || n.contains('tashriq')) {
    return kRitualGuidance['mina_days'];
  }
  if (n.contains('tarwiyah') || n.contains('tarwiya')) {
    return kRitualGuidance['mina'];
  }

  // --- Stations / lieux ---
  if (n.contains('arafat') || n.contains('arafa')) return kRitualGuidance['arafat'];
  if (n.contains('muzdalifa')) return kRitualGuidance['muzdalifah'];
  if (n.contains('ihram') || n.contains('sacralisation')) {
    return kRitualGuidance['ihram'];
  }

  // --- Actes ---
  if (n.contains('lapidation') || n.contains('jamra') || n.contains('jamarat') ||
      n.contains('aqaba') || n.contains('aqabah')) {
    return kRitualGuidance['ramy'];
  }
  if (n.contains('sacrifice') || n.contains('hady') || n.contains('hadaya') ||
      n.contains('qurbani')) {
    return kRitualGuidance['hady'];
  }
  if (n.contains('rasage') || n.contains('halq') || n.contains('taqsir') ||
      n.contains('coupe des cheveux') || n.contains('coupe')) {
    return kRitualGuidance['halq'];
  }

  // --- Génériques (en dernier) ---
  if (n.contains("sa'i") || n.contains('safa') || n.contains('marwa') ||
      n.contains('sa’i')) {
    return kRitualGuidance['sai'];
  }
  if (n.contains('tawaf')) return kRitualGuidance['tawaf'];
  if (n.contains('mina')) return kRitualGuidance['mina'];
  return null;
}
