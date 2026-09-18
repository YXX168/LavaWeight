import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/lava_theme.dart';
import 'home_view.dart';
import 'record_view.dart';
import 'settings_view.dart';
import 'trends_view.dart';

class MainScaffold extends StatefulWidget {
  final StorageService storage;
  const MainScaffold({super.key, required this.storage});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  void _addRecord() {
    widget.storage.exitDemo();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecordView(storage: widget.storage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.storage,
    builder: (context, _) => Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeView(
            key: const PageStorageKey('home'),
            storage: widget.storage,
            onRecord: _addRecord,
            onProfile: () => setState(() => _index = 2),
          ),
          TrendsView(
            key: const PageStorageKey('trends'),
            storage: widget.storage,
          ),
          SettingsView(
            key: const PageStorageKey('settings'),
            storage: widget.storage,
          ),
        ],
      ),
      bottomNavigationBar: ColoredBox(
        key: const ValueKey('main-bottom-navigation'),
        color: LavaTheme.background,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
            child: Row(
              children: [
                _item('今日', Icons.home_outlined, Icons.home_rounded, 0),
                _item(
                  '趋势',
                  Icons.bar_chart_rounded,
                  Icons.bar_chart_rounded,
                  1,
                ),
                _item(
                  '我的',
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  2,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _item(String label, IconData icon, IconData selected, int index) =>
      Expanded(
        child: Semantics(
          selected: _index == index,
          button: true,
          label: label,
          child: InkWell(
            onTap: () => setState(() => _index = index),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _index == index ? selected : icon,
                    size: 25,
                    color: _index == index
                        ? LavaTheme.lavaPink
                        : LavaTheme.textMuted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: _index == index
                          ? LavaTheme.textPrimary
                          : LavaTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _index == index
                          ? LavaTheme.lavaPink
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
