import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  String? nomeCompleto;
  String? email;
  String? createdAt;
  User({
    this.nomeCompleto,
    this.email,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nome_completo': nomeCompleto,
      'email': email,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      nomeCompleto:
          map['nome_completo'] != null ? map['nome_completo'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      createdAt: map['created_at'] != null ? map['created_at'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
