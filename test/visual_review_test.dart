@Tags(['visual'])
library;

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lava_weight/main.dart';
import 'package:lava_weight/models/user_profile.dart';
import 'package:lava_weight/models/weight_record.dart';
import 'package:lava_weight/services/storage_service.dart';
import 'package:lava_weight/views/record_view.dart';
import 'test_store.dart';

void main() {
  testWidgets('render real application screens for design review', (
    tester,
  ) async {
    final fontPath = Platform.environment['LAVA_REVIEW_FONT'];
    if (fontPath != null) {
      final bytes = File(fontPath).readAsBytesSync();
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
    final iconFontPath = Platform.environment['LAVA_ICON_FONT'];
    if (iconFontPath != null && File(iconFontPath).existsSync()) {
      final iconBytes = File(iconFontPath).readAsBytesSync();
      final iconLoader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(iconBytes)));
      await iconLoader.load();
    }
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = StorageService(TestStore());
    await storage.saveProfile(const UserProfile(motionEnabled: false));
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: LavaWeightApp(storage: storage),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold).first);
    await tester.runAsync(() async {
      for (final asset in ['home', 'trends', 'record']) {
        await precacheImage(
          AssetImage('assets/images/${asset}_lava.png'),
          context,
        );
      }
    });
    await tester.pumpAndSettle();

    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/visual-review/$name.png');
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('01-home-empty');
    storage.showDemo();
    await tester.pumpAndSettle();
    await capture('02-home-demo');
    await tester.tap(find.text('趋势'));
    await tester.pumpAndSettle();
    await capture('03-trends');
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await capture('05-settings');
    storage.exitDemo();
    await storage.saveRecord(
      WeightRecord(id: 'visual', weightKg: 68.5, recordedAt: DateTime.now()),
    );
    await tester.pumpAndSettle();
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => RecordView(storage: storage)),
    );
    await tester.pumpAndSettle();
    await capture('04-record');
  });
}
