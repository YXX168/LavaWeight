import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/weight_record.dart';
import '../models/user_profile.dart';
import 'state_store.dart';

class BackupData {
  final UserProfile profile;
  final List<WeightRecord> records;
  const BackupData(this.profile, this.records);
}

class StorageService extends ChangeNotifier {
  final StateStore _store;
  List<WeightRecord> _records = [];
  UserProfile _profile = const UserProfile();
  List<WeightRecord>? _demo;
  Future<void> _pending = Future<void>.value();
  String? loadError;

  StorageService(this._store);

  Future<void> load() async {
    try {
      final raw = await _store.read();
      if (raw != null) {
        final data = parseBackup(raw);
        _records = _sorted(data.records);
        _profile = data.profile;
      }
    } catch (_) {
      loadError = '本地数据暂时无法读取。原数据已保留，请重试。';
    }
  }

  bool get isDemo => _demo != null;
  List<WeightRecord> get records => List.unmodifiable(_demo ?? _records);
  UserProfile get profile => isDemo
      ? _profile.copyWith(
          heightCm: 175,
          targetWeightKg: 65,
          initialWeightKg: 72,
        )
      : _profile;
  UserProfile get savedProfile => _profile;
  WeightRecord? get latestRecord => records.isEmpty ? null : records.first;
  double? get latestDifference => records.length < 2
      ? null
      : _round(records[0].weightKg - records[1].weightKg);
  double? get totalChange => records.isEmpty
      ? null
      : _round(
          records.first.weightKg -
              (profile.initialWeightKg > 0
                  ? profile.initialWeightKg
                  : records.last.weightKg),
        );

  static double _round(double value) => double.parse(value.toStringAsFixed(1));
  static List<WeightRecord> _sorted(Iterable<WeightRecord> value) =>
      value.toList()..sort((a, b) {
        final result = b.recordedAt.compareTo(a.recordedAt);
        return result != 0 ? result : b.id.compareTo(a.id);
      });

  // Serialize all mutations; memory changes only after the SQLite transaction succeeds.
  Future<void> _enqueue(Future<void> Function() action) {
    final operation = _pending.then((_) => action());
    _pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _commit(List<WeightRecord> records, UserProfile profile) async {
    if (loadError != null) throw StateError('原数据未能读取，暂不能写入');
    final sorted = _sorted(records);
    await _store.write(_encode(sorted, profile));
    _records = sorted;
    _profile = profile;
    notifyListeners();
  }

  Future<void> saveRecord(WeightRecord record) => _enqueue(() async {
    if (isDemo) throw StateError('请先退出演示预览');
    record.validate();
    await _commit([
      ..._records.where((r) => r.id != record.id),
      record,
    ], _profile);
  });

  Future<void> deleteRecord(String id) => _enqueue(() async {
    if (isDemo) throw StateError('演示记录不能修改');
    await _commit(_records.where((r) => r.id != id).toList(), _profile);
  });

  Future<void> saveProfile(UserProfile profile) => _enqueue(() async {
    profile.validate();
    await _commit(_records, profile);
  });

  void showDemo({DateTime? now}) {
    final day = now ?? DateTime.now();
    const weights = [
      68.5,
      68.8,
      68.9,
      69.1,
      69.0,
      69.4,
      69.2,
      69.6,
      69.5,
      69.8,
      69.7,
      70.0,
      69.9,
      70.2,
      70.1,
      70.4,
      70.2,
      70.3,
    ];
    _demo = [
      for (var i = 0; i < weights.length; i++)
        WeightRecord(
          id: 'demo_$i',
          weightKg: weights[i],
          recordedAt: day.subtract(Duration(days: i)),
          note: i == 0 ? '演示记录' : null,
        ),
    ];
    notifyListeners();
  }

  void exitDemo() {
    _demo = null;
    notifyListeners();
  }

  String _encode(List<WeightRecord> records, UserProfile profile) =>
      const JsonEncoder.withIndent('  ').convert({
        'app': 'LavaWeight',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'profile': profile.toJson(),
        'records': records.map((r) => r.toJson()).toList(),
      });

  String exportBackupJson() {
    if (loadError != null) throw StateError('请先恢复本地数据读取');
    return _encode(_records, _profile);
  }

  static BackupData parseBackup(String raw) {
    if (raw.length > 10000000) throw const FormatException('备份文件过大');
    final data = jsonDecode(raw);
    if (data is! Map<String, dynamic> ||
        data['app'] != 'LavaWeight' ||
        data['version'] != 1 ||
        data['profile'] is! Map<String, dynamic> ||
        data['records'] is! List) {
      throw const FormatException('不是受支持的流光体重备份');
    }
    final profile = UserProfile.fromJson(
      data['profile'] as Map<String, dynamic>,
    );
    final source = data['records'] as List;
    if (source.length > 50000) throw const FormatException('记录数量过多');
    final ids = <String>{};
    final records = <WeightRecord>[];
    for (final item in source) {
      if (item is! Map<String, dynamic>) throw const FormatException('记录格式错误');
      final record = WeightRecord.fromJson(item);
      if (!ids.add(record.id)) throw const FormatException('存在重复记录编号');
      records.add(record);
    }
    return BackupData(profile, records);
  }

  Future<void> importBackupJson(String raw) => _enqueue(() async {
    final data = parseBackup(raw);
    await _commit(data.records, data.profile);
    _demo = null;
    notifyListeners();
  });

  Future<void> retryLoad() async {
    loadError = null;
    await load();
    notifyListeners();
  }
}
