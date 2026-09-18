import 'dart:ui';
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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.storage,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: LavaTheme.background,
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: [
                  HomeView(storage: widget.storage),
                  TrendsView(storage: widget.storage),
                  SettingsView(storage: widget.storage),
                ],
              ),

              // Floating Glassmorphic Bottom Dock
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xB31A0B22),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: LavaTheme.glassBorder,
                          width: 1.0,
                        ),
                        boxShadow: LavaTheme.cardShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            icon: Icons.home_filled,
                            label: '今日',
                            index: 0,
                          ),
                          _buildNavItem(
                            icon: Icons.show_chart,
                            label: '趋势',
                            index: 1,
                          ),

                          // Center Floating Quick Add Button
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RecordView(storage: widget.storage),
                                ),
                              );
                            },
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LavaTheme.buttonGradient,
                                boxShadow: LavaTheme.buttonGlowShadow,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: LavaTheme.textPrimary,
                                size: 26,
                              ),
                            ),
                          ),

                          _buildNavItem(
                            icon: Icons.tune,
                            label: '我的',
                            index: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? LavaTheme.lavaPeach : LavaTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? LavaTheme.textPrimary : LavaTheme.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

