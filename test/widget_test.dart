import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lava_weight/main.dart';
import 'package:lava_weight/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LavaWeightApp smoke test renders home screen properly',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    await tester.pumpWidget(LavaWeightApp(storage: storage));
    await tester.pump();

    // Verify main headers are present
    expect(find.text('体重日记'), findsOneWidget);
    expect(find.text('今天的体重'), findsOneWidget);
    expect(find.text('+ 记录体重'), findsOneWidget);
    expect(find.text('起始体重'), findsOneWidget);
    expect(find.text('目标体重'), findsOneWidget);
  });
}
