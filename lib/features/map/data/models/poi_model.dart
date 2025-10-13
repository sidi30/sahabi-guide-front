import 'package:google_maps_flutter/google_maps_flutter.dart';

enum PoiType {
  hotel,
  hospital,
  mosque,
  restaurant,
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
  });

  factory PoiModel.fromJson(Map<String, dynamic> json) {
    // Parse coordinates from GeoJSON
    final geometry = json['geometry'];
    double lat = 21.4225; // Default Makkah
    double lng = 39.8262;

    if (geometry != null) {
      if (geometry['type'] == 'Point') {
        final coordinates = geometry['coordinates'] as List;
        lng = coordinates[0].toDouble();
        lat = coordinates[1].toDouble();
      }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'geometry': {
        'type': 'Point',
        'coordinates': [coordinates.longitude, coordinates.latitude],
      },
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'properties': additionalInfo,
    };
  }

  static PoiType _parsePoiType(String? type) {
    switch (type?.toLowerCase()) {
      case 'hotel':
        return PoiType.hotel;
      case 'hospital':
        return PoiType.hospital;
      case 'mosque':
      case 'holy_site':
        return PoiType.mosque;
      case 'restaurant':
        return PoiType.restaurant;
      case 'hajj_site':
        return PoiType.hajjSite;
      case 'transport':
        return PoiType.transport;
      case 'airport':
        return PoiType.airport;
      default:
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
}

