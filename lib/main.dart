import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'theme/lava_theme.dart';
import 'views/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark immersive system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: LavaTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);

  runApp(LavaWeightApp(storage: storage));
}

class LavaWeightApp extends StatelessWidget {
  final StorageService storage;

  const LavaWeightApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LavaWeight 流光体重',
      debugShowCheckedModeBanner: false,
      theme: LavaTheme.themeData,
      home: MainScaffold(storage: storage),
    );
  }
}
