import 'dart:io';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';

import '../../../../core/utils/app_logger.dart';

/// Une zone couverte par un fond de carte vectoriel embarqué.
class OfflineMapRegion {
  final String id;
  final String label;
  final String assetPath;
  final LatLng center;

  /// Emprise du fichier PMTiles : hors de cette boîte, aucune tuile n'existe.
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  const OfflineMapRegion({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.center,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  bool contains(double lat, double lng) =>
      lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
}

/// Fonds de carte vectoriels embarqués dans l'application (PMTiles).
///
/// Aucun réseau n'est nécessaire pour afficher, déplacer ou zoomer la carte :
/// les tuiles sont livrées avec l'app et rendues localement. C'est ce que le
/// SDK Google Maps ne permet pas — il ne sait pas pré-télécharger ses tuiles,
/// et hors ligne la carte reste grise.
///
/// Les fichiers `.pmtiles` doivent être recopiés hors du bundle : la lecture
/// d'une archive PMTiles se fait par accès aléatoire sur un vrai fichier, ce
/// qu'un asset Flutter (compressé dans l'APK) ne permet pas.
class OfflineTilesService {
  OfflineTilesService();

  /// Version du jeu de tuiles. Incrémenter à chaque régénération des assets
  /// (`scripts/build_offline_tiles.sh`) : le nom de fichier en dépend, donc
  /// une nouvelle version remplace la copie locale de l'ancienne.
  static const String tilesVersion = 'v1-20260726';

  static const OfflineMapRegion makkah = OfflineMapRegion(
    id: 'makkah',
    label: 'La Mecque',
    assetPath: 'assets/maps/makkah.pmtiles',
    center: LatLng(21.4225, 39.8262),
    minLat: 21.24,
    maxLat: 21.58,
    minLng: 39.68,
    maxLng: 40.06,
  );

  static const OfflineMapRegion madinah = OfflineMapRegion(
    id: 'madinah',
    label: 'Médine',
    assetPath: 'assets/maps/madinah.pmtiles',
    center: LatLng(24.4672, 39.6112),
    minLat: 24.30,
    maxLat: 24.65,
    minLng: 39.42,
    maxLng: 39.80,
  );

  static const List<OfflineMapRegion> regions = [makkah, madinah];

  final Map<String, PmTilesVectorTileProvider> _providers = {};
  final Map<String, Future<PmTilesVectorTileProvider>> _pending = {};

  /// Région couvrant ces coordonnées, ou null si elles sont hors des fonds
  /// embarqués (le pèlerin est encore dans son pays, par exemple).
  static OfflineMapRegion? regionFor(double lat, double lng) {
    for (final region in regions) {
      if (region.contains(lat, lng)) return region;
    }
    return null;
  }

  static OfflineMapRegion? regionById(String id) {
    for (final region in regions) {
      if (region.id == id) return region;
    }
    return null;
  }

  /// Fournisseur de tuiles de la région, prêt à l'emploi.
  /// Le premier appel recopie l'archive hors du bundle (quelques Mo).
  Future<PmTilesVectorTileProvider> providerFor(OfflineMapRegion region) {
    final ready = _providers[region.id];
    if (ready != null) return Future.value(ready);

    return _pending.putIfAbsent(region.id, () async {
      try {
        final file = await _materialize(region);
        final provider = await PmTilesVectorTileProvider.fromSource(file.path);
        _providers[region.id] = provider;
        return provider;
      } finally {
        _pending.remove(region.id);
      }
    });
  }

  /// Copie l'asset dans le stockage de l'app si ce n'est pas déjà fait.
  Future<File> _materialize(OfflineMapRegion region) async {
    final dir = await getApplicationSupportDirectory();
    final mapsDir = Directory('${dir.path}/maps');
    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }

    final file = File('${mapsDir.path}/${region.id}.$tilesVersion.pmtiles');
    if (await file.exists() && await file.length() > 0) {
      return file;
    }

    AppLogger.info('Installation du fond de carte ${region.id} ($tilesVersion)');
    final data = await rootBundle.load(region.assetPath);
    // Écriture via un fichier temporaire : une copie interrompue (app tuée
    // pendant l'installation) ne doit pas laisser une archive tronquée qui
    // serait ensuite considérée comme valide.
    final tmp = File('${file.path}.part');
    await tmp.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    await tmp.rename(file.path);

    await _deleteObsoleteVersions(mapsDir, region);
    return file;
  }

  /// Supprime les fonds des versions précédentes pour ne pas accumuler
  /// plusieurs dizaines de Mo à chaque mise à jour de l'app.
  Future<void> _deleteObsoleteVersions(
    Directory mapsDir,
    OfflineMapRegion region,
  ) async {
    try {
      final keep = '${region.id}.$tilesVersion.pmtiles';
      await for (final entity in mapsDir.list()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (name.startsWith('${region.id}.') && name != keep) {
          await entity.delete();
        }
      }
    } catch (e) {
      AppLogger.warning('Nettoyage des anciens fonds de carte impossible',
          error: e);
    }
  }
}
