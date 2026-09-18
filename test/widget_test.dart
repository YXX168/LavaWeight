import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lava_weight/main.dart';
import 'package:lava_weight/models/user_profile.dart';
import 'package:lava_weight/services/storage_service.dart';
import 'package:lava_weight/theme/lava_theme.dart';
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

  testWidgets('bottom navigation reserves layout space on long pages', (
    tester,
  ) async {
    final storage = await setup(tester);
    storage.showDemo();
    await tester.pumpWidget(LavaWeightApp(storage: storage));
    await tester.pumpAndSettle();
    final nav = find.byKey(const ValueKey('main-bottom-navigation'));
    expect(nav, findsOneWidget);
    final navTop = tester.getTopLeft(nav).dy;

    await tester.tap(find.text('趋势'));
    await tester.pumpAndSettle();
    final trendsScroll = find.byType(CustomScrollView);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('history-demo_0')),
      500,
      scrollable: find.descendant(
        of: trendsScroll,
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getBottomRight(find.byKey(const ValueKey('history-demo_0'))).dy,
      lessThan(navTop),
    );

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    final settingsScroll = find.byType(SingleChildScrollView).last;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('settings-last-content')),
      500,
      scrollable: find
          .descendant(of: settingsScroll, matching: find.byType(Scrollable))
          .last,
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .getBottomRight(find.byKey(const ValueKey('settings-last-content')))
          .dy,
      lessThan(navTop),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('glass cards keep a visible fill after scroll', (tester) async {
    final storage = await setup(tester);
    storage.showDemo();
    await tester.pumpWidget(LavaWeightApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('趋势'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    final decorations = tester.widgetList<DecoratedBox>(
      find.byType(DecoratedBox),
    );
    expect(
      decorations.where((widget) {
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.gradient != null &&
            decoration.borderRadius != null;
      }),
      isNotEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('all text fields use rounded themed borders', (tester) async {
    final storage = await setup(tester);
    await tester.pumpWidget(LavaWeightApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    final theme = Theme.of(tester.element(find.byType(TextFormField).first));
    final border =
        theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
    expect(border.borderRadius.topLeft.x, 18);
    expect(border.borderSide.color, LavaTheme.glassBorderSubtle);
  });
}
