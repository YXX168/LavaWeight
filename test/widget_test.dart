import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lava_weight/main.dart';
import 'package:lava_weight/models/user_profile.dart';
import 'package:lava_weight/services/storage_service.dart';
import 'package:lava_weight/views/record_view.dart';
import 'package:lava_weight/widgets/lava_ruler.dart';
import 'test_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<StorageService> setup(
    WidgetTester tester, {
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = StorageService(TestStore());
    await storage.saveProfile(const UserProfile(motionEnabled: false));
    return storage;
  }

  testWidgets('new home is empty and demo remains explicitly labeled', (
    tester,
  ) async {
    final storage = await setup(tester);
    await tester.pumpWidget(LavaWeightApp(storage: storage));
    await tester.pumpAndSettle();
    expect(find.text('从第一笔记录开始'), findsOneWidget);
    expect(find.text('68.5'), findsNothing);
    await tester.ensureVisible(find.text('先看看效果'));
    await tester.tap(find.text('先看看效果'));
    await tester.pumpAndSettle();
    expect(find.text('演示预览 · 点击退出'), findsOneWidget);
    expect(find.text('68.5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('record editor saves and edits one persistent entry', (
    tester,
  ) async {
    final storage = await setup(tester);
    await tester.pumpWidget(LavaWeightApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('记录体重'));
    await tester.tap(find.text('记录体重'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('增加体重'));
    await tester.pump();
    await tester.ensureVisible(find.text('保存记录'));
    await tester.tap(find.text('保存记录'));
    await tester.pumpAndSettle();
    expect(storage.records.length, 1);
    expect(storage.records.single.weightKg, 70.1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      MaterialApp(
        home: RecordView(
          storage: storage,
          initialRecord: storage.records.single,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('编辑记录'), findsOneWidget);
  });

  testWidgets('ruler maps zero distance to the exact selected tick', (
    tester,
  ) async {
    var kg = 68.5;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => LavaRuler(
              currentWeight: kg,
              onWeightChanged: (value) => setState(() => kg = value),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('增加体重'));
    await tester.pump();
    expect(kg, 68.6);
    await tester.tap(find.byTooltip('减少体重'));
    await tester.pump();
    expect(kg, 68.5);
  });

  for (final width in [360.0, 430.0]) {
    testWidgets('all main pages fit at width $width', (tester) async {
      final storage = await setup(tester, width: width);
      storage.showDemo();
      await tester.pumpWidget(LavaWeightApp(storage: storage));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('趋势'));
      await tester.pumpAndSettle();
      expect(find.text('变化轨迹'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      expect(find.text('个人目标'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
