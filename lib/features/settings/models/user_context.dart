import 'package:hive/hive.dart';

part 'user_context.g.dart';

@HiveType(typeId: 2)
class UserContext {
  @HiveField(0)
  final String nickname;
  
  @HiveField(1)
  final String goals;
  
  @HiveField(2)
  final String values;
  
  @HiveField(3)
  final String constraints;

  UserContext({
    this.nickname = '',
    this.goals = '',
    this.values = '',
    this.constraints = '',
  });

  UserContext copyWith({
    String? nickname,
    String? goals,
    String? values,
    String? constraints,
  }) {
    return UserContext(
      nickname: nickname ?? this.nickname,
      goals: goals ?? this.goals,
      values: values ?? this.values,
      constraints: constraints ?? this.constraints,
    );
  }
}
