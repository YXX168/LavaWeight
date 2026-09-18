import '../models/weight_record.dart';

enum TrendPeriod { week, month, all }

class WeightStats {
  static List<WeightRecord> select(
    List<WeightRecord> records,
    TrendPeriod period,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final days = period == TrendPeriod.week ? 7 : 30;
    final start = today.subtract(Duration(days: days - 1));
    return records
        .where(
          (r) =>
              !r.recordedAt.isAfter(now) &&
              (period == TrendPeriod.all || !r.recordedAt.isBefore(start)),
        )
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }

  static int days(Iterable<WeightRecord> records) => records
      .map(
        (r) =>
            DateTime(r.recordedAt.year, r.recordedAt.month, r.recordedAt.day),
      )
      .toSet()
      .length;

  static double? average(List<WeightRecord> records) => records.isEmpty
      ? null
      : records.fold<double>(0, (sum, r) => sum + r.weightKg) / records.length;

  static double? change(List<WeightRecord> records) => records.length < 2
      ? null
      : records.last.weightKg - records.first.weightKg;

  static String weight(double? kg, bool jin) =>
      kg == null ? '—' : (kg * (jin ? 2 : 1)).toStringAsFixed(1);

  static String delta(double? kg, bool jin) {
    if (kg == null) return '—';
    final value = kg * (jin ? 2 : 1);
    return '${value > 0 ? '+' : (value < 0 ? '−' : '')}${value.abs().toStringAsFixed(1)}';
  }
}
