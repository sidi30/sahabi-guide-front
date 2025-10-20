import 'package:google_maps_flutter/google_maps_flutter.dart';

enum PoiType {
  hotel,
  hospital,
  mosque,
  restaurant,
  pharmacy,
  water,
  consulate,
  rally,
  shop,
  holySite,
  hajjSite,
  transport,
  airport,
  other,
}

class PoiModel {
  final String id;
  final String name;
  final String? description;
  final PoiType type;
  final LatLng coordinates;
  final String? address;
  final String? phone;
  final String? imageUrl;
  final Map<String, dynamic>? additionalInfo;
  final String? agencyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PoiModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.coordinates,
    this.address,
    this.phone,
    this.imageUrl,
    this.additionalInfo,
    this.agencyId,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory pour le format GeoController (/api/v1/geo/pois)
  factory PoiModel.fromGeoApi(Map<String, dynamic> json) {
    double lat = json['lat']?.toDouble() ?? 21.4225;
    double lng = json['lng']?.toDouble() ?? 39.8262;

    // Extraire metadata pour description, address, phone
    final metadata = json['metadata'] as Map<String, dynamic>?;
    
    return PoiModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'POI sans nom',
      description: metadata?['description']?.toString(),
      type: _parsePoiType(json['type']),
      coordinates: LatLng(lat, lng),
      address: metadata?['address']?.toString(),
      phone: metadata?['phone']?.toString(),
      imageUrl: metadata?['imageUrl']?.toString(),
      additionalInfo: metadata,
      agencyId: json['agencyId']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }

  /// Factory pour le format PoiController (/api/v1/poi) - données de test
  factory PoiModel.fromTestApi(Map<String, dynamic> json) {
    // Parse coordinates from GeoJSON
    final geometry = json['geometry'];
    double lat = 21.4225; // Default Makkah
    double lng = 39.8262;

    if (geometry != null && geometry['type'] == 'Point') {
      final coordinates = geometry['coordinates'] as List;
      lng = coordinates[0].toDouble();
      lat = coordinates[1].toDouble();
    }

    return PoiModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'POI sans nom',
      description: json['description'],
      type: _parsePoiType(json['type']),
      coordinates: LatLng(lat, lng),
      address: json['address'],
      phone: json['phone'],
      imageUrl: json['imageUrl'],
      additionalInfo: json['properties'] as Map<String, dynamic>?,
    );
  }

  /// Factory automatique qui détecte le format
  factory PoiModel.fromJson(Map<String, dynamic> json) {
    // Si on a 'lat' et 'lng' directement, c'est le format GeoAPI
    if (json.containsKey('lat') && json.containsKey('lng')) {
      return PoiModel.fromGeoApi(json);
    }
    // Sinon, c'est le format test avec geometry
    return PoiModel.fromTestApi(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name.toUpperCase(),
      'lat': coordinates.latitude,
      'lng': coordinates.longitude,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'metadata': additionalInfo,
      'agencyId': agencyId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Parse le type de POI depuis différents formats
  static PoiType _parsePoiType(String? type) {
    if (type == null) return PoiType.other;
    
    final typeUpper = type.toUpperCase();
    final typeLower = type.toLowerCase();
    
    switch (typeUpper) {
      case 'HOTEL':
        return PoiType.hotel;
      case 'HOSPITAL':
        return PoiType.hospital;
      case 'MOSQUE':
        return PoiType.mosque;
      case 'RESTAURANT':
        return PoiType.restaurant;
      case 'PHARMACY':
        return PoiType.pharmacy;
      case 'WATER':
        return PoiType.water;
      case 'CONSULATE':
        return PoiType.consulate;
      case 'RALLY':
        return PoiType.rally;
      case 'SHOP':
        return PoiType.shop;
      default:
        // Gérer les types du PoiController
        if (typeLower == 'holy_site') return PoiType.holySite;
        if (typeLower == 'hajj_site') return PoiType.hajjSite;
        if (typeLower == 'transport') return PoiType.transport;
        if (typeLower == 'airport') return PoiType.airport;
        return PoiType.other;
    }
  }

  String get typeLabel {
    switch (type) {
      case PoiType.hotel:
        return 'Hôtel';
      case PoiType.hospital:
        return 'Hôpital';
      case PoiType.mosque:
        return 'Mosquée';
      case PoiType.restaurant:
        return 'Restaurant';
      case PoiType.pharmacy:
        return 'Pharmacie';
      case PoiType.water:
        return 'Point d\'eau';
      case PoiType.consulate:
        return 'Consulat';
      case PoiType.rally:
        return 'Point de rassemblement';
      case PoiType.shop:
        return 'Magasin';
      case PoiType.holySite:
        return 'Site sacré';
      case PoiType.hajjSite:
        return 'Site Hajj';
      case PoiType.transport:
        return 'Transport';
      case PoiType.airport:
        return 'Aéroport';
      case PoiType.other:
        return 'Autre';
    }
  }

  /// Convertit le type au format backend (majuscules)
  String get typeBackend {
    switch (type) {
      case PoiType.holySite:
        return 'MOSQUE'; // Les sites sacrés sont des mosquées
      case PoiType.hajjSite:
        return 'RALLY'; // Les sites hajj sont des points de rassemblement
      case PoiType.transport:
      case PoiType.airport:
        return 'OTHER';
      default:
        return type.name.toUpperCase();
    }
  }
}
