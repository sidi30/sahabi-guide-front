import 'dart:convert';

/// Où en est un SOS vis-à-vis du serveur.
///
/// Ces états sont montrés tels quels au pèlerin : aucun d'eux ne doit pouvoir
/// être atteint sans preuve. [sent] en particulier n'est posé qu'après une
/// réponse du serveur portant l'identifiant de l'alerte créée.
enum SosDeliveryStatus {
  /// Persisté localement, en attente d'une tentative d'envoi.
  pending,

  /// Requête HTTP en vol.
  sending,

  /// Le serveur a confirmé la création de l'alerte.
  sent,

  /// Envoi impossible (refus du serveur, ou trop de tentatives) : il faut une
  /// action — réessai manuel, ou retour du réseau.
  failed,
}

/// Provenance de la position jointe au SOS.
///
/// Un secours ne doit jamais confondre « mesuré à l'instant » et « lieu déclaré
/// il y a deux jours ». Le repli Masjid al-Haram de `UserLocationService` n'a
/// délibérément pas d'équivalent ici : une position inventée serait pire que
/// pas de position du tout, donc elle devient [none].
enum SosLocationOrigin {
  /// Fix GPS obtenu pendant le déclenchement.
  freshGps,

  /// Dernier fix GPS connu, plus ancien mais réel.
  lastKnownGps,

  /// Lieu choisi manuellement par le pèlerin dans l'app.
  declaredPlace,

  /// Aucune position : le SOS part quand même.
  none,
}

/// Un appel au secours, de sa création locale jusqu'à sa confirmation serveur.
///
/// [clientAlertId] est généré une seule fois, à la création, et réutilisé à
/// chaque tentative : c'est la clé d'idempotence côté serveur, donc ce qui rend
/// le réessai sûr (pas de doublon d'alerte pour un même appui).
class SosRequest {
  const SosRequest({
    required this.clientAlertId,
    required this.createdAt,
    required this.status,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.capturedAt,
    this.locationOrigin = SosLocationOrigin.none,
    this.message,
    this.attempts = 0,
    this.lastError,
    this.requiresLogin = false,
    this.serverAlertId,
    this.confirmedAt,
    this.acknowledged = false,
  });

  final String clientAlertId;
  final DateTime createdAt;
  final SosDeliveryStatus status;

  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final DateTime? capturedAt;
  final SosLocationOrigin locationOrigin;

  final String? message;

  /// Nombre de tentatives d'envoi déjà effectuées (affiché au pèlerin).
  final int attempts;

  /// Dernière erreur rencontrée, conservée pour l'affichage et le diagnostic.
  final String? lastError;

  /// L'échec vient de l'absence de session valide : le message technique
  /// n'aiderait pas, il faut dire « reconnectez-vous ».
  final bool requiresLogin;

  /// Identifiant renvoyé par le serveur — présent seulement si [status] vaut
  /// [SosDeliveryStatus.sent].
  final String? serverAlertId;
  final DateTime? confirmedAt;

  /// Le pèlerin a vu et fermé la confirmation : l'entrée peut quitter l'écran.
  final bool acknowledged;

  bool get hasPosition => latitude != null && longitude != null;

  /// En cours d'acheminement : rien n'est encore confirmé, l'UI doit rester
  /// visible et ne surtout pas annoncer un succès.
  bool get isInFlight =>
      status == SosDeliveryStatus.pending || status == SosDeliveryStatus.sending;

  SosRequest copyWith({
    SosDeliveryStatus? status,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    DateTime? capturedAt,
    SosLocationOrigin? locationOrigin,
    String? message,
    int? attempts,
    String? lastError,
    bool clearLastError = false,
    bool? requiresLogin,
    String? serverAlertId,
    DateTime? confirmedAt,
    bool? acknowledged,
  }) {
    return SosRequest(
      clientAlertId: clientAlertId,
      createdAt: createdAt,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      capturedAt: capturedAt ?? this.capturedAt,
      locationOrigin: locationOrigin ?? this.locationOrigin,
      message: message ?? this.message,
      attempts: attempts ?? this.attempts,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      requiresLogin: clearLastError ? false : (requiresLogin ?? this.requiresLogin),
      serverAlertId: serverAlertId ?? this.serverAlertId,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  /// Corps envoyé au serveur. `clientAlertId` y est toujours, c'est lui qui
  /// garantit qu'un réessai ne crée pas une seconde alerte.
  Map<String, dynamic> toRequestBody() => {
        'clientAlertId': clientAlertId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
        if (capturedAt != null) 'capturedAt': capturedAt!.toUtc().toIso8601String(),
        if (message != null && message!.isNotEmpty) 'message': message,
      };

  Map<String, dynamic> toJson() => {
        'clientAlertId': clientAlertId,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'latitude': latitude,
        'longitude': longitude,
        'accuracyMeters': accuracyMeters,
        'capturedAt': capturedAt?.toIso8601String(),
        'locationOrigin': locationOrigin.name,
        'message': message,
        'attempts': attempts,
        'lastError': lastError,
        'requiresLogin': requiresLogin,
        'serverAlertId': serverAlertId,
        'confirmedAt': confirmedAt?.toIso8601String(),
        'acknowledged': acknowledged,
      };

  static SosRequest? tryParse(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static SosRequest fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    return SosRequest(
      clientAlertId: json['clientAlertId'] as String,
      createdAt: createdAt ?? DateTime.now(),
      status: SosDeliveryStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SosDeliveryStatus.pending,
      ),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
      capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? ''),
      locationOrigin: SosLocationOrigin.values.firstWhere(
        (o) => o.name == json['locationOrigin'],
        orElse: () => SosLocationOrigin.none,
      ),
      message: json['message'] as String?,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
      requiresLogin: json['requiresLogin'] as bool? ?? false,
      serverAlertId: json['serverAlertId'] as String?,
      confirmedAt: DateTime.tryParse(json['confirmedAt'] as String? ?? ''),
      acknowledged: json['acknowledged'] as bool? ?? false,
    );
  }
}
