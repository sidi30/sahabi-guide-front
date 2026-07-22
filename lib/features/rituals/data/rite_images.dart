/// Illustrations officielles (guide Ihram — HAJ.GOV.SA) associées aux rites.
///
/// Images embarquées dans les assets (`assets/images/rites/`). Le guide officiel
/// couvre les thèmes de l'Ihram : on illustre donc le rite Ihram section par
/// section, et on pose une image d'en-tête sur les rites voisins (Talbiya,
/// arrivée à la Mosquée sacrée). Les autres rites n'ont pas d'image officielle
/// pour l'instant (visuels propres à produire).
class RiteImage {
  final String asset;
  final String caption;
  const RiteImage(this.asset, this.caption);
}

const _p = 'assets/images/rites/';

/// Galerie complète du guide Ihram officiel, section par section.
const List<RiteImage> _ihramGuide = [
  RiteImage('${_p}ihram_what-is-ihram.jpg', "Qu'est-ce que l'Ihram ?"),
  RiteImage('${_p}ihram_clothing.jpg', "La tenue d'Ihram"),
  RiteImage('${_p}ihram_ishtirat.jpg', "L'Ishtirat (condition)"),
  RiteImage('${_p}ihram_talbiyah.jpg', 'La Talbiyah'),
  RiteImage('${_p}ihram_mawaqit.jpg', 'Les Mawaqit'),
  RiteImage('${_p}ihram_prohibitions.jpg', "Les interdits de l'Ihram"),
  RiteImage('${_p}ihram_chafing.jpg', 'Prévention des irritations'),
  RiteImage('${_p}ihram_etiquette.jpg', "L'étiquette du Muhrim"),
];

/// Retourne les illustrations d'un rite d'après son nom (insensible à la casse).
/// Liste vide si aucune image officielle n'est disponible pour ce rite.
List<RiteImage> imagesForRitual(String? ritualName) {
  final n = (ritualName ?? '').toLowerCase();
  if (n.contains('ihram') || n.contains('sacralisation')) {
    return _ihramGuide; // guide complet par section
  }
  if (n.contains('talbiya')) {
    return const [RiteImage('${_p}ihram_talbiyah.jpg', 'La Talbiyah')];
  }
  if (n.contains('mecque') || n.contains('haram') || n.contains('mosquée')) {
    return const [RiteImage('${_p}ihram_what-is-ihram.jpg', 'Arrivée à la Mosquée sacrée')];
  }
  return const [];
}
