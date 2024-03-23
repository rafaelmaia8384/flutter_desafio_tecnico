// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'model_arquivo.dart';

class FileUpload {
  String? id;
  String? nomeUpload;
  String? url;
  Arquivo? arquivo;
  FileUpload({
    this.id,
    this.nomeUpload,
    this.url,
    this.arquivo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome_upload': nomeUpload,
      'url': url,
      'arquivo': arquivo?.toMap(),
    };
  }

  factory FileUpload.fromMap(Map<String, dynamic> map) {
    return FileUpload(
      id: map['id'] != null ? map['id'] as String : null,
      nomeUpload:
          map['nome_upload'] != null ? map['nome_upload'] as String : null,
      url: map['url'] != null ? map['url'] as String : null,
      arquivo: map['arquivo'] != null
          ? Arquivo.fromMap(map['arquivo'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FileUpload.fromJson(String source) =>
      FileUpload.fromMap(json.decode(source) as Map<String, dynamic>);
}
