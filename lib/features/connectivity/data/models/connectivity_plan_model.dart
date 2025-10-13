class ConnectivityPlanModel {
  final String id;
  final String name;
  final double dataGb;
  final double price;
  final String partner;
  final bool isActive;

  ConnectivityPlanModel({
    required this.id,
    required this.name,
    required this.dataGb,
    required this.price,
    required this.partner,
    this.isActive = true,
  });

  factory ConnectivityPlanModel.fromJson(Map<String, dynamic> json) {
    return ConnectivityPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dataGb: (json['dataGb'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      partner: json['partner']?.toString() ?? '',
      isActive: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dataGb': dataGb,
      'price': price,
      'partner': partner,
      'active': isActive,
    };
  }

  ConnectivityPlanModel copyWith({
    String? id,
    String? name,
    double? dataGb,
    double? price,
    String? partner,
    bool? isActive,
  }) {
    return ConnectivityPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dataGb: dataGb ?? this.dataGb,
      price: price ?? this.price,
      partner: partner ?? this.partner,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'ConnectivityPlanModel(name: $name, dataGb: $dataGb GB, price: ${price.toStringAsFixed(2)} SAR)';
  }
}


