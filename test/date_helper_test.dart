import 'package:flutter_test/flutter_test.dart';
import 'package:lava_weight/services/date_helper.dart';

void main() {
  group('DateHelper Tests', () {
    test('formatFullDate formats correctly with Chinese weekday', () {
      final dt = DateTime(2026, 9, 18); // 2026-09-18 is Friday
      final formatted = DateHelper.formatFullDate(dt);
      expect(formatted, '9月18日 · 周五');
    });

    test('formatDateTime formats date, weekday, and time', () {
      final dt = DateTime(2026, 9, 18, 8, 30);
      final formatted = DateHelper.formatDateTime(dt);
      expect(formatted, '09月18日 周五 · 08:30');
    });

    test('formatShortDateTime formats date and time', () {
      final dt = DateTime(2026, 9, 18, 8, 5);
      final formatted = DateHelper.formatShortDateTime(dt);
      expect(formatted, '09月18日 08:05');
    });

    test('formatTime formats time with padding', () {
      final dt = DateTime(2026, 9, 18, 9, 4);
      final formatted = DateHelper.formatTime(dt);
      expect(formatted, '09:04');
    });

    test('formatShortDate formats MM.dd', () {
      final dt = DateTime(2026, 9, 8);
      final formatted = DateHelper.formatShortDate(dt);
      expect(formatted, '09.08');
    });
  });
}
