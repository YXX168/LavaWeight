class UserProfile {
  final String nickname;
  final double heightCm;
  final double targetWeightKg;
  final double initialWeightKg;
  final bool useJin;

  const UserProfile({
    this.nickname = '探索者',
    this.heightCm = 175.0,
    this.targetWeightKg = 65.0,
    this.initialWeightKg = 72.0,
    this.useJin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'heightCm': heightCm,
      'targetWeightKg': targetWeightKg,
      'initialWeightKg': initialWeightKg,
      'useJin': useJin,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] as String? ?? '探索者',
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 65.0,
      initialWeightKg: (json['initialWeightKg'] as num?)?.toDouble() ?? 72.0,
      useJin: json['useJin'] as bool? ?? false,
    );
  }

  UserProfile copyWith({
    String? nickname,
    double? heightCm,
    double? targetWeightKg,
    double? initialWeightKg,
    bool? useJin,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      heightCm: heightCm ?? this.heightCm,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      initialWeightKg: initialWeightKg ?? this.initialWeightKg,
      useJin: useJin ?? this.useJin,
    );
  }
}
