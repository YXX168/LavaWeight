import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lava_weight/models/weight_record.dart';
import 'package:lava_weight/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = StorageService(prefs);
    });

    test('initializes with seeded demo data when empty', () {
      expect(storage.records.isNotEmpty, true);
      expect(storage.latestRecord?.weightKg, 68.5);
      expect(storage.records.length, 18);
    });

    test('latestDifference calculates diff between top two records', () {
      // top two: 68.5 and 68.8 -> diff is -0.3
      final diff = storage.latestDifference;
      expect(diff, -0.3);
    });

    test('saveRecord and deleteRecord updates list and notification', () async {
      final newRecord = WeightRecord(
        id: 'new_entry_999',
        weightKg: 67.9,
        recordedAt: DateTime.now().add(const Duration(minutes: 10)),
        note: '突破68kg',
      );

      await storage.saveRecord(newRecord);
      expect(storage.latestRecord?.id, 'new_entry_999');
      expect(storage.latestRecord?.weightKg, 67.9);

      await storage.deleteRecord('new_entry_999');
      expect(storage.latestRecord?.id != 'new_entry_999', true);
    });

    test('exportBackupJson and importBackupJson round-trip', () {
      final jsonBackup = storage.exportBackupJson();
      expect(jsonBackup.contains('LavaWeight'), true);

      final success = storage.importBackupJson(jsonBackup);
      expect(success, true);
    });

    test('importBackupJson rejects invalid payload', () {
      final success = storage.importBackupJson('{"app": "AnotherApp"}');
      expect(success, false);
    });
  });
}

