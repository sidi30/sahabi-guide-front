import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/features/map/data/services/offline_tiles_service.dart';

void main() {
  group('OfflineTilesService — couverture des emprises', () {
    test('Masjid al-Haram est couvert par le fond La Mecque', () {
      final region = OfflineTilesService.regionFor(21.4225, 39.8262);
      expect(region?.id, 'makkah');
    });

    test('Masjid an-Nabawi est couvert par le fond Médine', () {
      final region = OfflineTilesService.regionFor(24.4672, 39.6112);
      expect(region?.id, 'madinah');
    });

    test('les sites du Hajj sont dans le fond La Mecque', () {
      // Mina, Muzdalifah, Arafat : le pèlerin y passe sans réseau utilisable.
      expect(OfflineTilesService.regionFor(21.4133, 39.8933)?.id, 'makkah');
      expect(OfflineTilesService.regionFor(21.3833, 39.9367)?.id, 'makkah');
      expect(OfflineTilesService.regionFor(21.3549, 39.9841)?.id, 'makkah');
    });

    test('une position hors emprise ne renvoie aucune région', () {
      // Djeddah n'est pas embarquée : l'app ne doit pas prétendre le contraire.
      expect(OfflineTilesService.regionFor(21.5433, 39.1728), isNull);
      // Niamey.
      expect(OfflineTilesService.regionFor(13.5116, 2.1254), isNull);
    });

    test('les emprises de Makkah et Madinah ne se chevauchent pas', () {
      for (final region in OfflineTilesService.regions) {
        for (final other in OfflineTilesService.regions) {
          if (identical(region, other)) continue;
          final overlaps = region.contains(other.center.latitude,
              other.center.longitude);
          expect(overlaps, isFalse,
              reason: '${region.id} contient le centre de ${other.id}');
        }
      }
    });

    test('chaque région contient son propre centre', () {
      for (final region in OfflineTilesService.regions) {
        expect(
          region.contains(region.center.latitude, region.center.longitude),
          isTrue,
          reason: '${region.id} ne contient pas son centre',
        );
      }
    });
  });

  group('OfflineTilesService — assets embarqués', () {
    test('les archives PMTiles déclarées existent dans le dépôt', () {
      for (final region in OfflineTilesService.regions) {
        final file = File(region.assetPath);
        expect(file.existsSync(), isTrue,
            reason: 'Asset manquant : ${region.assetPath} '
                '(régénérer avec scripts/build_offline_tiles.sh)');
        // Une archive PMTiles v3 fait au minimum quelques centaines de Ko ;
        // un fichier quasi vide signale une extraction ratée.
        expect(file.lengthSync(), greaterThan(200 * 1024),
            reason: '${region.assetPath} semble tronqué');
      }
    });

    test('les archives commencent par la signature PMTiles v3', () {
      for (final region in OfflineTilesService.regions) {
        final header = File(region.assetPath).openSync().readSync(8);
        // Magic "PMTiles" + version 3.
        expect(String.fromCharCodes(header.sublist(0, 7)), 'PMTiles');
        expect(header[7], 3);
      }
    });
  });
}
