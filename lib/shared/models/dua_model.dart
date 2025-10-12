class DuaModel {
  final String id;
  final String text;
  final String translation;
  final String tag;

  const DuaModel({
    required this.id,
    required this.text,
    required this.translation,
    required this.tag,
  });

  DuaModel copyWith({
    String? id,
    String? text,
    String? translation,
    String? tag,
  }) {
    return DuaModel(
      id: id ?? this.id,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      tag: tag ?? this.tag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'translation': translation,
      'tag': tag,
    };
  }

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      id: json['id'] as String,
      text: json['text'] as String,
      translation: json['translation'] as String,
      tag: json['tag'] as String,
    );
  }

  @override
  String toString() {
    return 'DuaModel(id: $id, text: $text, translation: $translation, tag: $tag)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DuaModel &&
        other.id == id &&
        other.text == text &&
        other.translation == translation &&
        other.tag == tag;
  }

  @override
  int get hashCode {
    return id.hashCode ^ text.hashCode ^ translation.hashCode ^ tag.hashCode;
  }
}
