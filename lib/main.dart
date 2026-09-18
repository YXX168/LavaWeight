import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/state_store.dart';
import 'services/storage_service.dart';
import 'theme/lava_theme.dart';
import 'views/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: LavaTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  try {
    final storage = StorageService(await SqliteStateStore.open());
    await storage.load();
    runApp(LavaWeightApp(storage: storage));
  } catch (_) {
    runApp(
      MaterialApp(
        theme: LavaTheme.themeData,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('暂时无法打开本地数据'),
                SizedBox(height: 16),
                FilledButton(onPressed: main, child: Text('重试')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LavaWeightApp extends StatelessWidget {
  final StorageService storage;
  const LavaWeightApp({super.key, required this.storage});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '流光体重',
    debugShowCheckedModeBanner: false,
    theme: LavaTheme.themeData,
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: MainScaffold(storage: storage),
  );
}
