import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_record.dart';
import '../models/user_profile.dart';

class StorageService extends ChangeNotifier {
  static const String _recordsKey = 'lava_weight_records_v1';
  static const String _profileKey = 'lava_user_profile_v1';

  final SharedPreferences _prefs;
  List<WeightRecord> _records = [];
  UserProfile _profile = const UserProfile();

  StorageService(this._prefs) {
    _loadFromPrefs();
  }

  List<WeightRecord> get records => List.unmodifiable(_records);
  UserProfile get profile => _profile;

  WeightRecord? get latestRecord => _records.isNotEmpty ? _records.first : null;

  WeightRecord? get previousRecord =>
      _records.length > 1 ? _records[1] : null;

  double? get latestDifference {
    if (_records.length < 2) return null;
    final diff = _records[0].weightKg - _records[1].weightKg;
    return double.parse(diff.toStringAsFixed(1));
  }

  double? get totalChange {
    if (_records.isEmpty) return null;
    final diff = _records.first.weightKg - _profile.initialWeightKg;
    return double.parse(diff.toStringAsFixed(1));
  }

  void _loadFromPrefs() {
    // Load Profile
    final profileJson = _prefs.getString(_profileKey);
    if (profileJson != null) {
      try {
        final map = jsonDecode(profileJson) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(map);
      } catch (e) {
        debugPrint('Failed to load profile: $e');
      }
    }

    // Load Records
    final recordsJson = _prefs.getString(_recordsKey);
    if (recordsJson != null) {
      try {
        final list = jsonDecode(recordsJson) as List<dynamic>;
        _records = list
            .map((item) => WeightRecord.fromJson(item as Map<String, dynamic>))
            .toList();
        _sortRecords();
      } catch (e) {
        debugPrint('Failed to load records: $e');
      }
    }

    // If empty on first launch, seed realistic demo data matching the approved concept board
    if (_records.isEmpty) {
      seedDemoData(notify: false);
    }
  }

  void _sortRecords() {
    _records.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Future<void> _persistRecords() async {
    final list = _records.map((r) => r.toJson()).toList();
    await _prefs.setString(_recordsKey, jsonEncode(list));
  }

  Future<void> _persistProfile() async {
    await _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
  }

  Future<void> saveRecord(WeightRecord record) async {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      _records[index] = record;
    } else {
      _records.add(record);
    }
    _sortRecords();
    await _persistRecords();
    notifyListeners();
  }

  Future<void> deleteRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _persistRecords();
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _persistProfile();
    notifyListeners();
  }

  void seedDemoData({bool notify = true}) {
    final now = DateTime.now();
    // 18 days of weight history leading to 68.5 kg, matching the design concept board
    final demoWeights = [
      68.5, 68.8, 68.9, 69.1, 69.0, 69.4, 69.2,
      69.6, 69.5, 69.8, 69.7, 70.0, 69.9, 70.2,
      70.1, 70.4, 70.2, 70.3
    ];

    _records = [];
    for (int i = 0; i < demoWeights.length; i++) {
      final date = now.subtract(Duration(days: i, hours: i * 2 % 5));
      _records.add(
        WeightRecord(
          id: 'demo_${date.millisecondsSinceEpoch}',
          weightKg: demoWeights[i],
          recordedAt: date,
          mood: i == 0 ? 'great' : (i % 3 == 0 ? 'good' : 'neutral'),
          note: i == 0 ? '晨起空腹称重，状态很好' : (i == 5 ? '今日运动后打卡' : null),
        ),
      );
    }
    _sortRecords();
    _persistRecords();
    if (notify) notifyListeners();
  }

  String exportBackupJson() {
    final data = {
      'app': 'LavaWeight',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': _profile.toJson(),
      'records': _records.map((r) => r.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  bool importBackupJson(String jsonStr) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (data['app'] != 'LavaWeight') {
        return false;
      }
      if (data['profile'] is Map<String, dynamic>) {
        _profile = UserProfile.fromJson(data['profile'] as Map<String, dynamic>);
        _persistProfile();
      }
      if (data['records'] is List<dynamic>) {
        final list = data['records'] as List<dynamic>;
        _records = list
            .map((item) => WeightRecord.fromJson(item as Map<String, dynamic>))
            .toList();
        _sortRecords();
        _persistRecords();
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Backup import failed: $e');
      return false;
    }
  }

  Future<void> clearAll() async {
    _records.clear();
    await _persistRecords();
    notifyListeners();
  }
}

