import 'package:toki_app/types/string.dart';

class User {
  final String id;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.email,
    required this.name,
  });

  User.fromJson(dynamic json)
      : id = json['id'],
        email = json['email'],
        name = json['name'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }

  String get initials {
    final splitted = name.split(' ');
    final first = splitted[0][0].toUpperCase();
    final second = splitted.length > 1
        ? splitted[1][0].toUpperCase()
        : splitted[0].last().toUpperCase();

    return '$first$second';
  }
}
