import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lava_weight/models/weight_record.dart';
import 'package:lava_weight/models/user_profile.dart';
import 'package:lava_weight/services/storage_service.dart';
import 'test_store.dart';

WeightRecord record(String id, double weight) =>
    WeightRecord(id: id, weightKg: weight, recordedAt: DateTime(2025, 8, 1));

void main() {
  test(
    'new account is empty; demo preview never writes personal records',
    () async {
      final disk = TestStore();
      final storage = StorageService(disk);
      await storage.load();
      expect(storage.records, isEmpty);
      storage.showDemo();
      expect(storage.records.length, 18);
      expect(disk.value, isNull);
      expect(jsonDecode(storage.exportBackupJson())['records'], isEmpty);
      storage.exitDemo();
      expect(storage.records, isEmpty);
    },
  );
  test('save, edit, delete and restart retain exact personal state', () async {
    final disk = TestStore();
    final storage = StorageService(disk);
    await storage.saveRecord(record('one', 70));
    await storage.saveRecord(record('one', 69));
    final restart = StorageService(disk);
    await restart.load();
    expect(restart.records.single.weightKg, 69);
    await restart.deleteRecord('one');
    final emptyRestart = StorageService(disk);
    await emptyRestart.load();
    expect(emptyRestart.records, isEmpty);
  });
  test('concurrent writes serialize and retain every saved entry', () async {
    final storage = StorageService(TestStore());
    await Future.wait(
      List.generate(20, (i) => storage.saveRecord(record('r$i', 60 + i / 10))),
    );
    expect(storage.records.length, 20);
  });
  test(
    'failed persistence never reports modified memory or loses old record',
    () async {
      final disk = TestStore();
      final storage = StorageService(disk);
      await storage.saveRecord(record('one', 70));
      final old = disk.value;
      disk.failWrite = true;
      await expectLater(storage.deleteRecord('one'), throwsStateError);
      expect(storage.records.single.weightKg, 70);
      expect(disk.value, old);
      disk.failWrite = false;
      await storage.saveRecord(record('two', 71));
      expect(storage.records.length, 2);
    },
  );
  test(
    'malformed import is fully validated before changing profile or records',
    () async {
      final disk = TestStore();
      final storage = StorageService(disk);
      await storage.saveRecord(record('one', 70));
      await storage.saveProfile(const UserProfile(nickname: 'Original'));
      final before = disk.value;
      final data =
          jsonDecode(storage.exportBackupJson()) as Map<String, dynamic>;
      data['profile']['nickname'] = 'Must not change';
      data['records'] = [
        record('ok', 60).toJson(),
        {'id': 'broken'},
      ];
      await expectLater(
        storage.importBackupJson(jsonEncode(data)),
        throwsA(anything),
      );
      expect(storage.profile.nickname, 'Original');
      expect(disk.value, before);
    },
  );
  test(
    'future backup versions, missing fields and duplicate IDs are rejected',
    () async {
      final storage = StorageService(TestStore());
      await storage.saveRecord(record('one', 70));
      final data =
          jsonDecode(storage.exportBackupJson()) as Map<String, dynamic>;
      data['version'] = 2;
      expect(
        () => StorageService.parseBackup(jsonEncode(data)),
        throwsFormatException,
      );
      data['version'] = 1;
      data['records'] = [
        record('dup', 60).toJson(),
        record('dup', 61).toJson(),
      ];
      expect(
        () => StorageService.parseBackup(jsonEncode(data)),
        throwsFormatException,
      );
      expect(
        () => StorageService.parseBackup('{"app":"LavaWeight"}'),
        throwsFormatException,
      );
    },
  );
  test('valid import round-trips and remains after restart', () async {
    final source = StorageService(TestStore());
    await source.saveRecord(record('one', 67.5));
    final disk = TestStore();
    final restored = StorageService(disk);
    await restored.importBackupJson(source.exportBackupJson());
    final restart = StorageService(disk);
    await restart.load();
    expect(restart.records.single.weightKg, 67.5);
  });
  test(
    'corrupt existing data is retained and writes blocked until recovered',
    () async {
      final disk = TestStore('{broken');
      final storage = StorageService(disk);
      await storage.load();
      expect(storage.loadError, isNotNull);
      await expectLater(
        storage.saveRecord(record('one', 70)),
        throwsStateError,
      );
      expect(disk.value, '{broken');
    },
  );
}
