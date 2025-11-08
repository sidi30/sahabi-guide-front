enum ConnectivityStatus {
  active,
  inactive,
  suspended,
  expired;

  static ConnectivityStatus fromString(String? status) {
    if (status == null) return ConnectivityStatus.inactive;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return ConnectivityStatus.active;
      case 'SUSPENDED':
        return ConnectivityStatus.suspended;
      case 'EXPIRED':
        return ConnectivityStatus.expired;
      default:
        return ConnectivityStatus.inactive;
    }
  }

  String toBackendString() {
    return name.toUpperCase();
  }
}

class ConnectivitySubscriptionModel {
  final String? id;
  final String userId;
  final String planId;
  final String? planName;
  final String? esimEid;
  final int balanceMb;
  final ConnectivityStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ConnectivitySubscriptionModel({
    this.id,
    required this.userId,
    required this.planId,
    this.planName,
    this.esimEid,
    required this.balanceMb,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ConnectivitySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ConnectivitySubscriptionModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? json['pilgrimId']?.toString() ?? '',
      planId: json['planId']?.toString() ?? '',
      planName: json['planName']?.toString(),
      esimEid: json['esimEid']?.toString(),
      balanceMb: json['balanceMb'] ?? 0,
      status: ConnectivityStatus.fromString(json['status']?.toString()),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'planId': planId,
      if (planName != null) 'planName': planName,
      if (esimEid != null) 'esimEid': esimEid,
      'balanceMb': balanceMb,
      'status': status.toBackendString(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ConnectivitySubscriptionModel copyWith({
    String? id,
    String? userId,
    String? planId,
    String? planName,
    String? esimEid,
    int? balanceMb,
    ConnectivityStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConnectivitySubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      esimEid: esimEid ?? this.esimEid,
      balanceMb: balanceMb ?? this.balanceMb,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get balanceGb => balanceMb / 1024.0;

  bool get isActive => status == ConnectivityStatus.active;

  @override
  String toString() {
    return 'ConnectivitySubscriptionModel(id: $id, status: ${status.name}, balance: ${balanceGb.toStringAsFixed(2)} GB)';
  }
}















