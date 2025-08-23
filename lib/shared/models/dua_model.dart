import 'dart:convert';

class DuaModel {
  final String id;
  final String text;
  final String translation;
  final String tag;

  DuaModel({
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'translation': translation,
      'tag': tag,
    };
  }

  factory DuaModel.fromMap(Map<String, dynamic> map) {
    return DuaModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      translation: map['translation'] ?? '',
      tag: map['tag'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DuaModel.fromJson(String source) => 
      DuaModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DuaModel(id: $id, text: $text, translation: $translation, tag: $tag)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is DuaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}