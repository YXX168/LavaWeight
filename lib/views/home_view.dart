import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weight_record.dart';
import '../services/bmi_calculator.dart';
import '../services/storage_service.dart';
import '../theme/lava_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';
import '../widgets/lava_trend_chart.dart';
import 'record_view.dart';

class HomeView extends StatelessWidget {
  final StorageService storage;

  const HomeView({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('M月d日 · EEEE', 'zh_CN').format(now);
    final latest = storage.latestRecord;
    final diff = storage.latestDifference;
    final profile = storage.profile;

    final currentWeightKg = latest?.weightKg ?? profile.initialWeightKg;
    final displayWeight =
        profile.useJin ? currentWeightKg * 2 : currentWeightKg;
    final unitStr = profile.useJin ? '斤' : 'kg';

    final bmi = BMICalculator.calculateBMI(currentWeightKg, profile.heightCm);
    final bmiCategory = BMICalculator.getCategory(bmi);

    final recentSeven = storage.records.take(7).toList();

    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/home_lava.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),

        // Dark Ambient Vignette
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x2013071A), Color(0x6013071A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '体重日记',
                          style: TextStyle(
                            color: LavaTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: LavaTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LavaTheme.glassFill,
                        border:
                            Border.all(color: LavaTheme.glassBorder, width: 1),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: LavaTheme.textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Weight Hero Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今天的体重',
                      style: TextStyle(
                        color: LavaTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          displayWeight.toStringAsFixed(1),
                          style: const TextStyle(
                            color: LavaTheme.textPrimary,
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          unitStr,
                          style: const TextStyle(
                            color: LavaTheme.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Diff Pill & BMI Badge
                    Row(
                      children: [
                        if (diff != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: diff <= 0
                                  ? const Color(0x3310B981)
                                  : const Color(0x33F59E0B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: diff <= 0
                                    ? LavaTheme.success
                                    : LavaTheme.warning,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  diff <= 0
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: diff <= 0
                                      ? LavaTheme.success
                                      : LavaTheme.warning,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '较上次 ${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    color: diff <= 0
                                        ? LavaTheme.success
                                        : LavaTheme.warning,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x332A0F38),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: LavaTheme.glassBorderSubtle,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'BMI $bmi · ${bmiCategory.label}',
                            style: const TextStyle(
                              color: LavaTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Quick Target & Initial Weight Row
                GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                        '起始体重',
                        '${profile.initialWeightKg.toStringAsFixed(1)} kg',
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: LavaTheme.glassBorderSubtle,
                      ),
                      _buildQuickStat(
                        '目标体重',
                        '${profile.targetWeightKg.toStringAsFixed(1)} kg',
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: LavaTheme.glassBorderSubtle,
                      ),
                      _buildQuickStat(
                        '累计变化',
                        storage.totalChange != null
                            ? '${storage.totalChange! > 0 ? '+' : ''}${storage.totalChange!.toStringAsFixed(1)} kg'
                            : '--',
                        highlightColor: LavaTheme.lavaPeach,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Recent 7 Days Trend Card
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '近7次变化',
                            style: TextStyle(
                              color: LavaTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            recentSeven.isNotEmpty
                                ? '最新 ${recentSeven.first.weightKg.toStringAsFixed(1)} kg'
                                : '',
                            style: const TextStyle(
                              color: LavaTheme.lavaPeach,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LavaTrendChart(
                        records: recentSeven,
                        height: 160,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Action Button: + 记录体重
                GlowingButton(
                  label: '+ 记录体重',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecordView(storage: storage),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80), // bottom nav padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, {Color? highlightColor}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: LavaTheme.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: highlightColor ?? LavaTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
