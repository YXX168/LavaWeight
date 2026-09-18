class UserProfile {
  final String nickname;
  final double heightCm;
  final double targetWeightKg;
  final double initialWeightKg;
  final bool useJin;
  final bool motionEnabled;

  const UserProfile({
    this.nickname = '',
    this.heightCm = 0,
    this.targetWeightKg = 0,
    this.initialWeightKg = 0,
    this.useJin = false,
    this.motionEnabled = true,
  });

  void validate() {
    if (nickname.length > 40 ||
        !heightCm.isFinite ||
        (heightCm != 0 && (heightCm < 50 || heightCm > 250)) ||
        !targetWeightKg.isFinite ||
        (targetWeightKg != 0 &&
            (targetWeightKg < 20 || targetWeightKg > 300)) ||
        !initialWeightKg.isFinite ||
        (initialWeightKg != 0 &&
            (initialWeightKg < 20 || initialWeightKg > 300))) {
      throw const FormatException('个人设置数值不正确');
    }
  }

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'heightCm': heightCm,
    'targetWeightKg': targetWeightKg,
    'initialWeightKg': initialWeightKg,
    'useJin': useJin,
    'motionEnabled': motionEnabled,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final result = UserProfile(
      nickname: json['nickname'] as String? ?? '',
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 0,
      initialWeightKg: (json['initialWeightKg'] as num?)?.toDouble() ?? 0,
      useJin: json['useJin'] as bool? ?? false,
      motionEnabled: json['motionEnabled'] as bool? ?? true,
    );
    result.validate();
    return result;
  }

  UserProfile copyWith({
    String? nickname,
    double? heightCm,
    double? targetWeightKg,
    double? initialWeightKg,
    bool? useJin,
    bool? motionEnabled,
  }) => UserProfile(
    nickname: nickname ?? this.nickname,
    heightCm: heightCm ?? this.heightCm,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    initialWeightKg: initialWeightKg ?? this.initialWeightKg,
    useJin: useJin ?? this.useJin,
    motionEnabled: motionEnabled ?? this.motionEnabled,
  );
}
