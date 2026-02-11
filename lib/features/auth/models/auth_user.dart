class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarEmoji;
  final String? userContext;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarEmoji,
    this.userContext,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarEmoji: json['avatar_emoji'] as String?,
      userContext: json['user_context'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_emoji': avatarEmoji,
      'user_context': userContext,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  AppUser copyWith({
    String? name,
    String? email,
    String? avatarEmoji,
    String? userContext,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      userContext: userContext ?? this.userContext,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
