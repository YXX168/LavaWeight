import 'package:flutter_test/flutter_test.dart';
import 'package:lava_weight/models/weight_record.dart';
import 'package:lava_weight/services/weight_stats.dart';

void main() {
  final now = DateTime(2025, 8, 20, 12);
  WeightRecord at(int days, String id) => WeightRecord(
    id: id,
    weightKg: 70,
    recordedAt: now.subtract(Duration(days: days)),
  );
  test('empty selected interval never substitutes old data', () {
    expect(WeightStats.select([at(20, 'old')], TrendPeriod.week, now), isEmpty);
  });
  test(
    'weekly boundary includes seven local calendar days and excludes future',
    () {
      final records = [
        at(0, 'now'),
        at(6, 'six'),
        at(7, 'seven'),
        at(-1, 'future'),
      ];
      expect(
        WeightStats.select(records, TrendPeriod.week, now).map((r) => r.id),
        ['six', 'now'],
      );
    },
  );
  test('recorded days counts distinct dates rather than entries', () {
    expect(WeightStats.days([at(0, 'one'), at(0, 'two'), at(1, 'three')]), 2);
  });
  test('weight and deltas follow selected display unit', () {
    expect(WeightStats.weight(68.5, true), '137.0');
    expect(WeightStats.delta(-0.3, true), '−0.6');
    expect(WeightStats.average([]), isNull);
    expect(WeightStats.change([at(0, 'one')]), isNull);
  });
}
