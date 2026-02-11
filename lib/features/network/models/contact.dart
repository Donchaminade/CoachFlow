import 'package:freezed_annotation/freezed_annotation.dart';

// Standalone class to avoid build_runner/freezed dependency issues
class Contact {
  final String id;
  final String contactId;
  final String name;
  final String email;
  final String avatarEmoji;
  final DateTime createdAt;

  const Contact({
    required this.id,
    required this.contactId,
    required this.name,
    required this.email,
    this.avatarEmoji = '👤',
    required this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      contactId: json['contact_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarEmoji: json['avatar_emoji'] as String? ?? '👤',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contact_id': contactId,
      'name': name,
      'email': email,
      'avatar_emoji': avatarEmoji,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
