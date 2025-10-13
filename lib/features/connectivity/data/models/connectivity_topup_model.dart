class ConnectivityTopupModel {
  final String? id;
  final String subscriptionId;
  final double amountPaid;
  final int dataMb;
  final DateTime? createdAt;

  ConnectivityTopupModel({
    this.id,
    required this.subscriptionId,
    required this.amountPaid,
    required this.dataMb,
    this.createdAt,
  });

  factory ConnectivityTopupModel.fromJson(Map<String, dynamic> json) {
    return ConnectivityTopupModel(
      id: json['id']?.toString(),
      subscriptionId: json['subscriptionId']?.toString() ?? '',
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      dataMb: json['dataMb'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'subscriptionId': subscriptionId,
      'amountPaid': amountPaid,
      'dataMb': dataMb,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  double get dataGb => dataMb / 1024.0;

  @override
  String toString() {
    return 'ConnectivityTopupModel(amount: $amountPaid SAR, data: ${dataGb.toStringAsFixed(2)} GB)';
  }
}


