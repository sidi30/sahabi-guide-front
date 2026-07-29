import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';

import '../../../../core/services/location_change_coordinator.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/services/user_location_service.dart';
import '../../../../shared/widgets/location_disclosure_dialog.dart';
import '../../../../shared/widgets/location_picker_sheet.dart';
import '../../data/models/poi_model.dart';
import '../../data/services/offline_tiles_service.dart';
import '../../data/services/poi_service.dart';

/// Ce que la carte affiche.
///
/// [mine] est la vue par défaut : les lieux que l'agence a attribués au pèlerin
/// depuis le back-office (son hôtel, et ce qui est rattaché à cet hôtel —
/// restaurant, pharmacie, mosquée). Les autres zones servent à explorer.
///
/// Les lieux saints sont répartis sur deux villes distantes de ~450 km : un
/// seul cadrage « La Mecque » rendait tous les POI de Médine invisibles.
enum MapArea { mine, makkah, madinah, aroundMe, all }

extension on MapArea {
  String get label {
    switch (this) {
      case MapArea.mine:
        return 'Mes lieux';
      case MapArea.makkah:
        return 'La Mecque';
      case MapArea.madinah:
        return 'Médine';
      case MapArea.aroundMe:
        return 'Autour de moi';
      case MapArea.all:
        return 'Tout';
    }
  }

  IconData get icon {
    switch (this) {
      case MapArea.mine:
        return Icons.star_outline;
      case MapArea.makkah:
        return Icons.location_city;
      case MapArea.madinah:
        return Icons.mosque_outlined;
      case MapArea.aroundMe:
        return Icons.my_location;
      case MapArea.all:
        return Icons.public;
    }
  }
}

class _AreaCenter {
  final LatLng center;
  final double radiusMeters;
  const _AreaCenter(this.center, this.radiusMeters);
}

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final PoiService _poiService = GetIt.I<PoiService>();
  final UserLocationService _locationService = GetIt.I<UserLocationService>();
  final OfflineTilesService _tilesService = GetIt.I<OfflineTilesService>();
  final TextEditingController _searchController = TextEditingController();

  // Données
  List<PoiModel> _allPois = const [];

  /// Lieux attribués au pèlerin (endpoint /geo/pois/mine). Vide pour un
  /// visiteur non connecté ou un pèlerin sans groupe.
  List<PoiModel> _myPois = const [];
  bool _myPoisLoaded = false;

  bool _isLoading = true;
  String? _error;
  bool _fromCache = false;
  DateTime? _cachedAt;

  // Fond de carte hors ligne
  OfflineMapRegion _tileRegion = OfflineTilesService.makkah;
  PmTilesVectorTileProvider? _tileProvider;
  String? _tileError;

  // Filtres
  String _selectedType = 'all';
  MapArea _area = MapArea.mine;
  String _query = '';

  // Position
  ResolvedLocation? _location;

  static const double _defaultZoom = 13.0;

  // Rayons couvrant l'agglomération et les sites du Hajj (Mina, Arafat,
  // Muzdalifah sont à moins de 25 km du Haram).
  static final Map<MapArea, _AreaCenter> _areaCenters = {
    MapArea.makkah: _AreaCenter(OfflineTilesService.makkah.center, 45000),
    MapArea.madinah: _AreaCenter(OfflineTilesService.madinah.center, 35000),
  };

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    // 1. Fond de carte embarqué : disponible sans réseau, dès le premier écran.
    unawaited(_loadTiles(_tileRegion));

    // 2. Cache POI : la carte est utilisable immédiatement, même hors ligne.
    final cached = await _poiService.getCachedPois();
    if (cached != null && mounted) {
      setState(() {
        _allPois = cached.pois;
        _fromCache = true;
        _cachedAt = cached.cachedAt;
        _isLoading = false;
      });
      _fitToVisiblePois();
    }

    // 3. Position (sans bloquer l'affichage des POI).
    unawaited(_resolveLocation());

    // 4. Lieux attribués au pèlerin, puis rafraîchissement réseau des POI.
    await _loadMyPois();
    await _loadPois(silent: cached != null);
  }

  Future<void> _loadMyPois() async {
    try {
      final result = await _poiService.loadMyPois();
      if (!mounted) return;
      setState(() {
        _myPois = result.pois;
        _myPoisLoaded = true;
        // Un visiteur sans lieux attribués ne doit pas tomber sur un écran
        // vide : on bascule sur La Mecque.
        if (_myPois.isEmpty && _area == MapArea.mine) _area = MapArea.makkah;
      });
      _fitToVisiblePois();
    } catch (e) {
      // 403 (visiteur non connecté) ou réseau : la vue « Mes lieux » est
      // simplement indisponible, le reste de la carte fonctionne.
      AppLogger.debug('Lieux attribués indisponibles: $e');
      if (!mounted) return;
      setState(() {
        _myPoisLoaded = true;
        if (_area == MapArea.mine) _area = MapArea.makkah;
      });
    }
  }

  Future<void> _loadTiles(OfflineMapRegion region) async {
    try {
      final provider = await _tilesService.providerFor(region);
      if (!mounted) return;
      setState(() {
        _tileRegion = region;
        _tileProvider = provider;
        _tileError = null;
      });
    } catch (e, s) {
      AppLogger.error('Fond de carte hors ligne indisponible',
          error: e, stackTrace: s);
      if (!mounted) return;
      setState(() => _tileError = 'Fond de carte indisponible');
    }
  }

  Future<void> _resolveLocation({bool forcePrompt = false}) async {
    try {
      if (forcePrompt && mounted) {
        final granted = await LocationDisclosureDialog.showAndRequest(context);
        if (!granted) return;
      }
      final resolved = await _locationService.resolve(forceGps: forcePrompt);
      if (!mounted) return;
      setState(() => _location = resolved);
    } catch (e) {
      AppLogger.warning('Position indisponible pour la carte', error: e);
    }
  }

  Future<void> _loadPois({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _poiService.loadPois();
      if (!mounted) return;
      setState(() {
        _allPois = result.pois;
        _fromCache = result.fromCache;
        _cachedAt = result.cachedAt;
        _isLoading = false;
        _error = null;
      });
      _fitToVisiblePois();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Une erreur réseau avec des POI en cache n'est pas bloquante :
        // le bandeau hors-ligne suffit.
        _error =
            _allPois.isEmpty ? 'Impossible de charger les lieux : $e' : null;
      });
    }
  }

  // ---------------------------------------------------------------- filtrage

  List<PoiModel> get _visiblePois {
    final q = _query.trim().toLowerCase();
    final areaCenter = _areaCenters[_area];

    // « Mes lieux » n'est pas une zone géographique : c'est la liste attribuée
    // par l'agence, qu'elle soit à La Mecque ou à Médine.
    final source = _area == MapArea.mine ? _myPois : _allPois;

    final filtered = source.where((poi) {
      if (_selectedType != 'all' && poi.type != _typeFromFilter(_selectedType)) {
        return false;
      }

      if (areaCenter != null) {
        final d = Geolocator.distanceBetween(
          areaCenter.center.latitude,
          areaCenter.center.longitude,
          poi.coordinates.latitude,
          poi.coordinates.longitude,
        );
        if (d > areaCenter.radiusMeters) return false;
      } else if (_area == MapArea.aroundMe) {
        final loc = _location;
        if (loc == null) return false;
        final d = Geolocator.distanceBetween(
          loc.latitude,
          loc.longitude,
          poi.coordinates.latitude,
          poi.coordinates.longitude,
        );
        if (d > 15000) return false;
      }

      if (q.isNotEmpty) {
        final haystack =
            '${poi.name} ${poi.typeLabel} ${poi.address ?? ''}'.toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();

    final origin = _originForDistances();
    if (origin != null) {
      filtered.sort((a, b) => _distanceMeters(origin, a.coordinates)
          .compareTo(_distanceMeters(origin, b.coordinates)));
    } else {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }
    return filtered;
  }

  LatLng? _originForDistances() {
    final loc = _location;
    if (loc != null && !loc.isApproximate) {
      return LatLng(loc.latitude, loc.longitude);
    }
    return null;
  }

  double _distanceMeters(LatLng from, LatLng to) => Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );

  PoiType? _typeFromFilter(String filter) {
    switch (filter) {
      case 'mosque':
        return PoiType.mosque;
      case 'hospital':
        return PoiType.hospital;
      case 'hotel':
        return PoiType.hotel;
      case 'restaurant':
        return PoiType.restaurant;
      case 'holySite':
        return PoiType.holySite;
      default:
        return null;
    }
  }

  // ------------------------------------------------------------------ caméra

  /// Le fond de carte n'existe que dans les emprises embarquées : suivre la
  /// caméra permet de basculer d'archive quand on passe de La Mecque à Médine.
  void _syncTileRegion(LatLng center) {
    final region =
        OfflineTilesService.regionFor(center.latitude, center.longitude);
    if (region == null || region.id == _tileRegion.id) return;
    unawaited(_loadTiles(region));
  }

  /// Cadre la caméra sur les POI affichés, afin qu'aucun lieu ne reste hors
  /// écran (cas Médine avec un cadrage figé sur La Mecque).
  void _fitToVisiblePois() {
    if (!mounted) return;
    final pois = _visiblePois;

    if (pois.isEmpty) {
      final fallback = _areaCenters[_area]?.center ??
          (_location != null
              ? LatLng(_location!.latitude, _location!.longitude)
              : OfflineTilesService.makkah.center);
      _moveTo(fallback, _defaultZoom);
      return;
    }

    if (pois.length == 1) {
      _moveTo(pois.first.coordinates, 16);
      return;
    }

    final bounds = LatLngBounds.fromPoints(
      pois.map((p) => p.coordinates).toList(),
    );
    _syncTileRegion(bounds.center);
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(48, 160, 48, 220),
          maxZoom: 16,
        ),
      );
    } catch (e) {
      // La caméra n'est pas encore prête (carte non montée) : le cadrage
      // sera refait au prochain chargement.
      AppLogger.debug('Cadrage carte différé: $e');
    }
  }

  void _moveTo(LatLng target, double zoom) {
    _syncTileRegion(target);
    try {
      _mapController.move(target, zoom);
    } catch (e) {
      AppLogger.debug('Déplacement carte différé: $e');
    }
  }

  void _changeArea(MapArea area) {
    setState(() => _area = area);
    final center = _areaCenters[area]?.center ??
        // « Mes lieux » : le fond suit l'hôtel attribué, qui peut être à
        // Médine alors que la carte affichait La Mecque.
        (area == MapArea.mine && _myPois.isNotEmpty
            ? _myPois.first.coordinates
            : null);
    if (center != null) {
      _syncTileRegion(center);
    }
    if (area == MapArea.aroundMe && _location == null) {
      unawaited(
          _resolveLocation(forcePrompt: true).then((_) => _fitToVisiblePois()));
      return;
    }
    _fitToVisiblePois();
  }

  void _changeFilter(String filter) {
    setState(() => _selectedType = filter);
    _fitToVisiblePois();
  }

  // ------------------------------------------------------------------- fiche

  void _showPoiDetails(PoiModel poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPoiDetailsSheet(poi),
    );
  }

  Widget _buildPoiDetailsSheet(PoiModel poi) {
    final origin = _originForDistances();
    final distance =
        origin == null ? null : _distanceMeters(origin, poi.coordinates);
    final bearing = origin == null
        ? null
        : Geolocator.bearingBetween(
            origin.latitude,
            origin.longitude,
            poi.coordinates.latitude,
            poi.coordinates.longitude,
          );

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.textSecondaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPoiColor(context, poi.type),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getPoiIcon(poi.type),
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poi.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          poi.typeLabel,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Rattachement : « votre hôtel », ou le lieu voisin de cet hôtel.
              if (_isAssignedToMe(poi)) ...[
                const SizedBox(height: 12),
                Builder(builder: (context) {
                  final hotel = _parentHotelOf(poi);
                  final distanceToHotel = hotel == null
                      ? null
                      : _distanceMeters(hotel.coordinates, poi.coordinates);
                  final text = hotel == null
                      ? 'Attribué par votre agence'
                      : 'À ${_formatDistance(distanceToHotel!)} de '
                          '${hotel.name}';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.warningColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 16, color: context.warningColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                                fontSize: 13, color: context.textPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 16),

              // Distance + cap : utilisables sans réseau, y compris à pied
              // dans la foule quand l'écran ne suffit pas.
              if (distance != null && bearing != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.navigation,
                          color: context.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        '${_formatDistance(distance)} · ${_compassLabel(bearing)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

              if (poi.description != null && poi.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  poi.description!,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.textPrimaryColor,
                    height: 1.5,
                  ),
                ),
              ],

              if (poi.phone != null) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _launch('tel:${poi.phone}'),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: context.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        poi.phone!,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (poi.address != null && poi.address!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: context.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        poi.address!,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),
              Text(
                '${poi.coordinates.latitude.toStringAsFixed(5)}, '
                '${poi.coordinates.longitude.toStringAsFixed(5)}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondaryColor,
                ),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _moveTo(poi.coordinates, 17.0);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.center_focus_strong),
                      label: const Text('Centrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      // Nécessite du réseau : l'itinéraire est délégué à
                      // l'application de navigation du téléphone.
                      onPressed: () => _launch(
                        'https://www.google.com/maps/dir/?api=1&destination='
                        '${poi.coordinates.latitude},${poi.coordinates.longitude}',
                      ),
                      icon: const Icon(Icons.directions),
                      label: const Text('Itinéraire'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action indisponible sur cet appareil')),
        );
      }
    } catch (e) {
      AppLogger.warning('Ouverture de $url impossible', error: e);
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(meters < 10000 ? 1 : 0)} km';
  }

  /// Cap en points cardinaux : plus lisible qu'un angle pour s'orienter à pied.
  String _compassLabel(double bearing) {
    const dirs = [
      'nord',
      'nord-est',
      'est',
      'sud-est',
      'sud',
      'sud-ouest',
      'ouest',
      'nord-ouest',
    ];
    final normalized = (bearing % 360 + 360) % 360;
    final index = ((normalized + 22.5) ~/ 45) % 8;
    return 'vers le ${dirs[index]}';
  }

  Color _getPoiColor(BuildContext context, PoiType type) {
    switch (type) {
      case PoiType.mosque:
      case PoiType.holySite:
        return context.primaryColor;
      case PoiType.hospital:
      case PoiType.pharmacy:
        return context.errorColor;
      case PoiType.hotel:
        return context.secondaryColor;
      case PoiType.restaurant:
        return const Color(0xFFF77F00);
      case PoiType.hajjSite:
        return context.accentColor;
      case PoiType.transport:
      case PoiType.airport:
        return const Color(0xFF6F4E37);
      default:
        return context.textSecondaryColor;
    }
  }

  IconData _getPoiIcon(PoiType type) {
    switch (type) {
      case PoiType.mosque:
      case PoiType.holySite:
        return Icons.eco_outlined;
      case PoiType.hospital:
        return Icons.local_hospital;
      case PoiType.pharmacy:
        return Icons.medication_outlined;
      case PoiType.hotel:
        return Icons.hotel;
      case PoiType.restaurant:
        return Icons.restaurant;
      case PoiType.hajjSite:
        return Icons.place;
      case PoiType.transport:
        return Icons.train;
      case PoiType.airport:
        return Icons.flight;
      case PoiType.water:
        return Icons.water_drop_outlined;
      case PoiType.rally:
        return Icons.groups_outlined;
      default:
        return Icons.location_on;
    }
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final pois = _visiblePois;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          _buildMap(context, pois),
          _buildTopBar(context),
          if (_isLoading)
            const Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          if (_error != null) _buildErrorOverlay(context),
          _buildPoiListSheet(context, pois),
          Positioned(
            right: 16,
            bottom: 230,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'map_my_location',
                  mini: true,
                  backgroundColor: context.surfaceColor,
                  foregroundColor: context.primaryColor,
                  tooltip: 'Ma position',
                  onPressed: () async {
                    await _resolveLocation(forcePrompt: true);
                    final loc = _location;
                    if (loc != null && !loc.isApproximate) {
                      _moveTo(LatLng(loc.latitude, loc.longitude), 16.0);
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'map_fit',
                  mini: true,
                  backgroundColor: context.surfaceColor,
                  foregroundColor: context.primaryColor,
                  tooltip: 'Voir tous les lieux affichés',
                  onPressed: _fitToVisiblePois,
                  child: const Icon(Icons.fit_screen),
                ),
              ],
            ),
          ),
          // L'urgence n'est plus ici : elle passe par le bouton SOS de la
          // coquille principale (file persistante + confirmation serveur).
          // L'ancien bouton visait /api/v1/alerts/emergency, qui n'existe pas.
          Positioned(
            bottom: 230,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionButton('Guide', Icons.phone_rounded,
                    context.accentColor, _callGuide),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context, List<PoiModel> pois) {
    final provider = _tileProvider;

    if (provider == null) {
      return Container(
        color: context.backgroundColor,
        child: Center(
          child: _tileError != null
              ? Text(_tileError!,
                  style: TextStyle(color: context.textSecondaryColor))
              : const CircularProgressIndicator(),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _tileRegion.center,
        initialZoom: _defaultZoom,
        minZoom: 9,
        maxZoom: 18,
        // Le fond n'existe que dans l'emprise embarquée : sans cette borne, un
        // glissement de doigt sortait de la zone couverte et l'écran devenait
        // blanc sans explication. Le passage La Mecque ↔ Médine se fait par
        // les onglets de zone, pas en faisant défiler 450 km de désert.
        cameraConstraint: CameraConstraint.containCenter(
          bounds: LatLngBounds(
            LatLng(_tileRegion.minLat, _tileRegion.minLng),
            LatLng(_tileRegion.maxLat, _tileRegion.maxLng),
          ),
        ),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture) _syncTileRegion(camera.center);
        },
      ),
      children: [
        VectorTileLayer(
          theme: isDark
              ? ProtomapsThemes.darkV4()
              : ProtomapsThemes.lightV4(),
          tileProviders: TileProviders({'protomaps': provider}),
          maximumZoom: provider.maximumZoom.toDouble(),
          // Les tuiles sont locales : pas de cache disque supplémentaire à
          // entretenir, et pas de TTL qui ferait « expirer » un fond hors ligne.
          fileCacheTtl: Duration.zero,
        ),
        MarkerLayer(markers: _buildMarkers(context, pois)),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 4),
            child: Container(
              color: context.surfaceColor.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: Text(
                '© OpenStreetMap',
                style: TextStyle(fontSize: 9, color: context.textSecondaryColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers(BuildContext context, List<PoiModel> pois) {
    final markers = <Marker>[];

    final loc = _location;
    if (loc != null && !loc.isApproximate) {
      markers.add(
        Marker(
          point: LatLng(loc.latitude, loc.longitude),
          width: 26,
          height: 26,
          child: Container(
            decoration: BoxDecoration(
              color: context.infoColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      );
    }

    for (final poi in pois) {
      // Un lieu attribué au pèlerin se repère au premier coup d'œil parmi les
      // POI génériques : c'est son hôtel, sa mosquée, son restaurant.
      final assigned = _isAssignedToMe(poi);
      final size = assigned ? 44.0 : 38.0;

      markers.add(
        Marker(
          point: poi.coordinates,
          width: size,
          height: size,
          child: GestureDetector(
            onTap: () => _showPoiDetails(poi),
            child: Container(
              decoration: BoxDecoration(
                color: _getPoiColor(context, poi.type),
                shape: BoxShape.circle,
                border: Border.all(
                  color: assigned ? context.warningColor : Colors.white,
                  width: assigned ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(_getPoiIcon(poi.type),
                  color: Colors.white, size: assigned ? 22 : 19),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  bool _isAssignedToMe(PoiModel poi) =>
      _myPois.any((mine) => mine.id == poi.id);

  /// L'hôtel de rattachement d'un lieu attribué, s'il est connu.
  PoiModel? _parentHotelOf(PoiModel poi) {
    final parentId = poi.parentPoiId;
    if (parentId == null) return null;
    for (final candidate in _myPois) {
      if (candidate.id == parentId) return candidate;
    }
    return null;
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: context.surfaceColor.withValues(alpha: 0.94),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Sélecteur de zone : c'est lui qui rend Médine atteignable.
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: MapArea.values
                    // Pas d'onglet « Mes lieux » sans lieux attribués
                    // (visiteur non connecté, pèlerin sans groupe).
                    .where((a) =>
                        a != MapArea.mine || !_myPoisLoaded || _myPois.isNotEmpty)
                    .map((a) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildAreaChip(context, a),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildFilterChip(context, 'all', 'Tous', Icons.all_inclusive),
                  _buildFilterChip(
                      context, 'mosque', 'Mosquées', Icons.eco_outlined),
                  _buildFilterChip(
                      context, 'holySite', 'Lieux saints', Icons.place),
                  _buildFilterChip(context, 'hotel', 'Hôtels', Icons.hotel),
                  _buildFilterChip(
                      context, 'restaurant', 'Restaurants', Icons.restaurant),
                  _buildFilterChip(
                      context, 'hospital', 'Santé', Icons.local_hospital),
                ],
              ),
            ),
            if (_fromCache) _buildOfflineBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    final at = _cachedAt;
    final label = at == null
        ? 'Lieux enregistrés sur l\'appareil'
        : 'Hors ligne — lieux enregistrés le '
            '${at.day.toString().padLeft(2, '0')}/${at.month.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.warningColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: context.warningColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: context.textPrimaryColor),
            ),
          ),
          GestureDetector(
            onTap: () => _loadPois(),
            child: Text(
              'Réessayer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.errorColor),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _error = null);
                  _loadPois();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Panneau glissant : liste des lieux affichés, triée par distance.
  /// Fonctionne intégralement hors ligne (POI en cache, fond de carte embarqué).
  Widget _buildPoiListSheet(BuildContext context, List<PoiModel> pois) {
    final origin = _originForDistances();

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.12,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textSecondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${pois.length} lieu${pois.length > 1 ? 'x' : ''} · ${_area.label}',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Changer ma position',
                      icon: const Icon(Icons.place_outlined, size: 20),
                      onPressed: () async {
                        final changed = await LocationPickerSheet.show(context);
                        if (!changed) return;
                        // Même changement de position que sur l'accueil :
                        // horaires et notifications suivent aussi.
                        unawaited(LocationChangeCoordinator.apply());
                        await _resolveLocation();
                        _fitToVisiblePois();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Rechercher un lieu…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: pois.isEmpty
                    ? ListView(
                        controller: scrollController,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              _area == MapArea.mine
                                  ? 'Aucun lieu ne vous a encore été attribué '
                                      'par votre agence.'
                                  : _allPois.isEmpty
                                      ? 'Aucun lieu enregistré. Connectez-vous à '
                                          'internet une fois pour les télécharger.'
                                      : 'Aucun lieu ne correspond à ce filtre.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: context.textSecondaryColor),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: pois.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final poi = pois[index];
                          final d = origin == null
                              ? null
                              : _distanceMeters(origin, poi.coordinates);
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: _getPoiColor(context, poi.type),
                              child: Icon(_getPoiIcon(poi.type),
                                  size: 18, color: Colors.white),
                            ),
                            title: Text(
                              poi.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              d == null
                                  ? poi.typeLabel
                                  : '${poi.typeLabel} · ${_formatDistance(d)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.center_focus_strong,
                                  size: 20),
                              tooltip: 'Centrer sur la carte',
                              onPressed: () => _moveTo(poi.coordinates, 17),
                            ),
                            onTap: () => _showPoiDetails(poi),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAreaChip(BuildContext context, MapArea area) {
    final selected = _area == area;
    return GestureDetector(
      onTap: () => _changeArea(area),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? context.primaryColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? context.primaryColor
                : context.textSecondaryColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(area.icon,
                size: 16,
                color: selected ? Colors.white : context.primaryColor),
            const SizedBox(width: 6),
            Text(
              area.label,
              style: TextStyle(
                color: selected ? Colors.white : context.textPrimaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String value, String label, IconData icon) {
    final isSelected = _selectedType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _changeFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? context.primaryColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? context.primaryColor
                  : context.textSecondaryColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: isSelected
                      ? context.primaryColor
                      : context.textSecondaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? context.primaryColor
                      : context.textPrimaryColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callGuide() async {
    try {
      await _poiService.callGuide();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Guide appelé avec succès'),
            backgroundColor: context.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }
}
