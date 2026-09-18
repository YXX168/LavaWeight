import 'package:lava_weight/services/state_store.dart';

class TestStore implements StateStore {
  String? value;
  bool failWrite = false;
  TestStore([this.value]);
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    await Future<void>.value();
    if (failWrite) throw StateError('simulated disk error');
    this.value = value;
  }
}
