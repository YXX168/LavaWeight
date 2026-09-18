import 'package:flutter_test/flutter_test.dart';
import 'package:lava_weight/models/user_profile.dart';
import 'package:lava_weight/models/weight_record.dart';

void main() {
  test('weight preserves kilograms, notes and time across serialization', () {
    final record = WeightRecord(
      id: 'one',
      weightKg: 68.5,
      recordedAt: DateTime(2025, 9, 1, 8, 30),
      note: '空腹',
      mood: 'good',
    );
    final restored = WeightRecord.fromJson(record.toJson());
    expect(restored.weightInJin, 137);
    expect(restored.note, '空腹');
    expect(restored.recordedAt, record.recordedAt);
  });
  test('rejects non-finite and invalid profile/weight inputs', () {
    expect(
      () => const UserProfile(heightCm: double.nan).validate(),
      throwsFormatException,
    );
    expect(
      () => const UserProfile(targetWeightKg: -1).validate(),
      throwsFormatException,
    );
    expect(
      () => WeightRecord(
        id: 'x',
        weightKg: double.infinity,
        recordedAt: DateTime(2025),
      ).validate(),
      throwsFormatException,
    );
    expect(
      () => WeightRecord(
        id: 'x',
        weightKg: 60,
        recordedAt: DateTime.now().add(const Duration(days: 1)),
      ).validate(),
      throwsFormatException,
    );
  });
  test('new profile does not invent personal body measurements', () {
    expect(const UserProfile().heightCm, 0);
    expect(const UserProfile().targetWeightKg, 0);
  });
}
