
class RitualModel {
  final String id;
  final String name;
  final int order;
  final String description;

  const RitualModel({
    required this.id,
    required this.name,
    required this.order,
    required this.description,
  });

  factory RitualModel.fromJson(Map<String, dynamic> json) {
    return RitualModel(
      id: json['id'] as String,
      name: json['name'] as String,
      order: json['order'] as int,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'description': description,
    };
  }

  RitualModel copyWith({
    String? id,
    String? name,
    int? order,
    String? description,
  }) {
    return RitualModel(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'RitualModel(id: $id, name: $name, order: $order, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RitualModel &&
        other.id == id &&
        other.name == name &&
        other.order == order &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ order.hashCode ^ description.hashCode;
  }
}
