import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:sahabi_guide/features/map/data/services/offline_tiles_service.dart';

/// Tuile XYZ contenant ces coordonnées au zoom donné (projection Web Mercator).
({int x, int y}) _tileAt(double lat, double lng, int zoom) {
  final n = math.pow(2, zoom).toDouble();
  final x = ((lng + 180.0) / 360.0 * n).floor();
  final latRad = lat * math.pi / 180.0;
  final y = ((1.0 -
              math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
          2.0 *
          n)
      .floor();
  return (x: x, y: y);
}

/// Vérifie que les archives embarquées contiennent réellement les tuiles des
/// lieux qui comptent — un fichier valide mais extrait sur la mauvaise emprise
/// passerait tous les autres tests et donnerait un écran vide sur le terrain.
void main() {
  Future<void> expectTileExists(
    OfflineMapRegion region,
    double lat,
    double lng,
    int zoom,
    String what,
  ) async {
    final archive = await PmTilesArchive.from(region.assetPath);
    try {
      final xy = _tileAt(lat, lng, zoom);
      final tile = await archive.tile(ZXY(zoom, xy.x, xy.y).toTileId());
      expect(tile.bytes(), isNotEmpty, reason: 'Tuile vide pour $what');
    } finally {
      await archive.close();
    }
  }

  group('Archives PMTiles embarquées', () {
    test('couvrent Masjid al-Haram au zoom rue', () async {
      await expectTileExists(
          OfflineTilesService.makkah, 21.4225, 39.8262, 15, 'Masjid al-Haram');
    });

    test('couvrent Mina et Arafat au zoom rue', () async {
      await expectTileExists(
          OfflineTilesService.makkah, 21.4133, 39.8933, 15, 'Mina');
      await expectTileExists(
          OfflineTilesService.makkah, 21.3549, 39.9841, 15, 'Arafat');
    });

    test('couvrent Masjid an-Nabawi au zoom rue', () async {
      await expectTileExists(OfflineTilesService.madinah, 24.4672, 39.6112, 15,
          'Masjid an-Nabawi');
    });

    test('annoncent bien les zooms 0 à 15', () async {
      for (final region in OfflineTilesService.regions) {
        final archive = await PmTilesArchive.from(region.assetPath);
        try {
          expect(archive.minZoom, 0, reason: region.id);
          expect(archive.maxZoom, 15, reason: region.id);
        } finally {
          await archive.close();
        }
      }
    });
  });
}
