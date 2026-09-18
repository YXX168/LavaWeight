import 'package:flutter_test/flutter_test.dart';
import 'package:lava_weight/models/weight_record.dart';
import 'package:lava_weight/models/user_profile.dart';

void main() {
  group('WeightRecord Model Tests', () {
    test('toJson and fromJson preserves data accurately', () {
      final now = DateTime(2026, 9, 18, 8, 30);
      final record = WeightRecord(
        id: 'test_123',
        weightKg: 68.5,
        recordedAt: now,
        note: '晨起空腹',
        mood: 'great',
      );

      final json = record.toJson();
      final fromJson = WeightRecord.fromJson(json);

      expect(fromJson.id, 'test_123');
      expect(fromJson.weightKg, 68.5);
      expect(fromJson.weightInJin, 137.0);
      expect(fromJson.recordedAt, now);
      expect(fromJson.note, '晨起空腹');
      expect(fromJson.mood, 'great');
      expect(fromJson, record);
    });

    test('copyWith works correctly', () {
      final record = WeightRecord(
        id: 'test_1',
        weightKg: 70.0,
        recordedAt: DateTime(2026, 9, 1),
      );

      final updated = record.copyWith(weightKg: 68.5, note: '持续减脂');
      expect(updated.id, 'test_1');
      expect(updated.weightKg, 68.5);
      expect(updated.note, '持续减脂');
    });
  });

  group('UserProfile Model Tests', () {
    test('default values and serialization', () {
      const profile = UserProfile();
      expect(profile.targetWeightKg, 65.0);
      expect(profile.initialWeightKg, 72.0);
      expect(profile.heightCm, 175.0);

      final json = profile.toJson();
      final fromJson = UserProfile.fromJson(json);

      expect(fromJson.targetWeightKg, 65.0);
      expect(fromJson.heightCm, 175.0);
      expect(fromJson.nickname, '探索者');
    });
  });
}
