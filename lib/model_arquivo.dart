// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Arquivo {
  String? type;
  List<int>? data;
  Arquivo({
    this.type,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'data': data,
    };
  }

  factory Arquivo.fromMap(Map<String, dynamic> map) {
    return Arquivo(
      type: map['type'] as String?,
      data: map['data'] != null
          ? (map['data'] as List)
              .map((item) => int.parse(item.toString()))
              .toList()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Arquivo.fromJson(String source) =>
      Arquivo.fromMap(json.decode(source) as Map<String, dynamic>);
}
