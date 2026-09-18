class WeightRecord {
  final String id;
  final double weightKg;
  final DateTime recordedAt;
  final String? note;
  final String? mood;

  const WeightRecord({
    required this.id,
    required this.weightKg,
    required this.recordedAt,
    this.note,
    this.mood,
  });

  double get weightInJin => weightKg * 2.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weightKg': weightKg,
      'recordedAt': recordedAt.toIso8601String(),
      'note': note,
      'mood': mood,
    };
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      note: json['note'] as String?,
      mood: json['mood'] as String?,
    );
  }

  WeightRecord copyWith({
    String? id,
    double? weightKg,
    DateTime? recordedAt,
    String? note,
    String? mood,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      recordedAt: recordedAt ?? this.recordedAt,
      note: note ?? this.note,
      mood: mood ?? this.mood,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          weightKg == other.weightKg &&
          recordedAt == other.recordedAt;

  @override
  int get hashCode => id.hashCode ^ weightKg.hashCode ^ recordedAt.hashCode;
}

