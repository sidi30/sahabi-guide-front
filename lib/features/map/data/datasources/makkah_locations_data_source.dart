import 'package:latlong2/latlong.dart';
import '../models/makkah_location_model.dart';

abstract class MakkahLocationsDataSource {
  List<MakkahLocationModel> getMakkahLocations();
  List<MakkahLocationModel> getLocationsByType(String type);
  MakkahLocationModel? getLocationById(String id);
}

class MakkahLocationsDataSourceImpl implements MakkahLocationsDataSource {
  static const List<MakkahLocationModel> _makkahLocations = [
    // Masjid al-Haram (Grand Mosque)
    MakkahLocationModel(
      id: 'masjid_al_haram',
      name: 'Masjid al-Haram',
      nameArabic: 'المسجد الحرام',
      coordinates: LatLng(21.4225, 39.8262),
      type: 'mosque',
      description: 'The holiest mosque in Islam surrounding the Kaaba',
      isImportant: true,
    ),

    // Kaaba
    MakkahLocationModel(
      id: 'kaaba',
      name: 'Kaaba',
      nameArabic: 'الكعبة',
      coordinates: LatLng(21.4225, 39.8262),
      type: 'holy_site',
      description: 'The most sacred site in Islam',
      isImportant: true,
    ),

    // Safa and Marwah Hills
    MakkahLocationModel(
      id: 'safa_marwah',
      name: 'Safa and Marwah Hills',
      nameArabic: 'الصفا والمروة',
      coordinates: LatLng(21.4236, 39.8270),
      type: 'holy_site',
      description: 'Hills where pilgrims perform Sa\'i ritual',
      isImportant: true,
    ),

    // Jabal al-Nour (Mountain of Light)
    MakkahLocationModel(
      id: 'jabal_al_nour',
      name: 'Jabal al-Nour',
      nameArabic: 'جبل النور',
      coordinates: LatLng(21.4594, 39.8544),
      type: 'mountain',
      description: 'Mountain where Cave Hira is located',
      isImportant: true,
    ),

    // Cave Hira
    MakkahLocationModel(
      id: 'cave_hira',
      name: 'Cave Hira',
      nameArabic: 'غار حراء',
      coordinates: LatLng(21.4600, 39.8550),
      type: 'cave',
      description: 'Cave where Prophet Muhammad received first revelation',
      isImportant: true,
    ),

    // Jabal Thawr
    MakkahLocationModel(
      id: 'jabal_thawr',
      name: 'Jabal Thawr',
      nameArabic: 'جبل ثور',
      coordinates: LatLng(21.3706, 39.8219),
      type: 'mountain',
      description: 'Mountain with the cave where Prophet hid during Hijra',
      isImportant: true,
    ),

    // Mina
    MakkahLocationModel(
      id: 'mina',
      name: 'Mina',
      nameArabic: 'منى',
      coordinates: LatLng(21.4120, 39.8884),
      type: 'hajj_site',
      description: 'Valley where pilgrims stay during Hajj',
      isImportant: true,
    ),

    // Arafat
    MakkahLocationModel(
      id: 'arafat',
      name: 'Mount Arafat',
      nameArabic: 'جبل عرفات',
      coordinates: LatLng(21.3544, 39.9844),
      type: 'hajj_site',
      description: 'Mountain where pilgrims gather on Day of Arafat',
      isImportant: true,
    ),

    // Muzdalifah
    MakkahLocationModel(
      id: 'muzdalifah',
      name: 'Muzdalifah',
      nameArabic: 'مزدلفة',
      coordinates: LatLng(21.3950, 39.9350),
      type: 'hajj_site',
      description: 'Sacred area between Mina and Arafat',
      isImportant: true,
    ),

    // King Abdulaziz International Airport
    MakkahLocationModel(
      id: 'jeddah_airport',
      name: 'King Abdulaziz Airport',
      nameArabic: 'مطار الملك عبدالعزيز',
      coordinates: LatLng(21.6796, 39.1564),
      type: 'airport',
      description: 'Main international airport serving Makkah pilgrims',
    ),

    // Hospitals
    MakkahLocationModel(
      id: 'king_faisal_hospital',
      name: 'King Faisal Hospital',
      nameArabic: 'مستشفى الملك فيصل',
      coordinates: LatLng(21.4167, 39.8167),
      type: 'hospital',
      description: 'Major hospital in Makkah',
    ),

    MakkahLocationModel(
      id: 'ajyad_hospital',
      name: 'Ajyad Emergency Hospital',
      nameArabic: 'مستشفى أجياد للطوارئ',
      coordinates: LatLng(21.4189, 39.8264),
      type: 'hospital',
      description: 'Emergency hospital near Masjid al-Haram',
    ),

    // Hotels near Haram
    MakkahLocationModel(
      id: 'abraj_al_bait',
      name: 'Abraj Al-Bait Clock Tower',
      nameArabic: 'أبراج البيت',
      coordinates: LatLng(21.4189, 39.8256),
      type: 'hotel',
      description: 'Luxury hotel complex overlooking Masjid al-Haram',
    ),

    // Transport Hubs
    MakkahLocationModel(
      id: 'makkah_metro',
      name: 'Makkah Metro Station',
      nameArabic: 'محطة مترو مكة',
      coordinates: LatLng(21.4200, 39.8300),
      type: 'transport',
      description: 'Metro station serving the Holy Mosque',
    ),
  ];

  @override
  List<MakkahLocationModel> getMakkahLocations() {
    return List.from(_makkahLocations);
  }

  @override
  List<MakkahLocationModel> getLocationsByType(String type) {
    return _makkahLocations.where((location) => location.type == type).toList();
  }

  @override
  MakkahLocationModel? getLocationById(String id) {
    try {
      return _makkahLocations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }
}