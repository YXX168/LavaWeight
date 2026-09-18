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

  double get weightInJin => weightKg * 2;

  void validate() {
    if (id.isEmpty ||
        id.length > 120 ||
        !weightKg.isFinite ||
        weightKg < 20 ||
        weightKg > 300 ||
        recordedAt.year < 2000 ||
        recordedAt.isAfter(DateTime.now()) ||
        (note?.length ?? 0) > 500 ||
        ![null, 'great', 'good', 'neutral', 'tired'].contains(mood)) {
      throw const FormatException('体重、日期或备注不正确');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'weightKg': weightKg,
    'recordedAt': recordedAt.toIso8601String(),
    'note': note,
    'mood': mood,
  };

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    final record = WeightRecord(
      id: json['id'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String).toLocal(),
      note: json['note'] as String?,
      mood: json['mood'] as String?,
    );
    record.validate();
    return record;
  }
}
