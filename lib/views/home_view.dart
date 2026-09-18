import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/date_helper.dart';
import '../services/storage_service.dart';
import '../services/weight_stats.dart';
import '../theme/lava_theme.dart';
import '../widgets/app_helpers.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';
import '../widgets/lava_background.dart';
import '../widgets/lava_trend_chart.dart';

class HomeView extends StatelessWidget {
  final StorageService storage;
  final VoidCallback onRecord;
  final VoidCallback onProfile;
  const HomeView({
    super.key,
    required this.storage,
    required this.onRecord,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final latest = storage.latestRecord;
    final jin = storage.profile.useJin;
    final unit = jin ? '斤' : 'kg';
    final now = DateTime.now();
    final isToday =
        latest != null && DateUtils.isSameDay(latest.recordedAt, now);
    final recent = WeightStats.select(storage.records, TrendPeriod.week, now);
    return PageBackdrop(
      image: 'home',
      motion: storage.profile.motionEnabled,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, bounds) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '体重',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateHelper.formatFullDate(now),
                            style: const TextStyle(
                              color: LavaTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onProfile,
                      tooltip: '个人设置',
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: LavaTheme.glassBorder),
                      ),
                      icon: const Icon(Icons.person_outline_rounded),
                    ),
                  ],
                ),
                if (storage.isDemo)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: InkWell(
                      onTap: storage.exitDemo,
                      child: const Text(
                        '演示预览 · 点击退出',
                        style: TextStyle(
                          fontSize: 12,
                          color: LavaTheme.lavaPink,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 48),
                Text(
                  latest == null ? '从第一笔记录开始' : (isToday ? '今天的体重' : '最近的体重'),
                  style: const TextStyle(
                    color: LavaTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          WeightStats.weight(latest?.weightKg, jin),
                          style: const TextStyle(
                            fontSize: 66,
                            height: 1.12,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 22,
                        color: LavaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  storage.latestDifference == null
                      ? (latest == null ? '把变化，交给时间' : '已保存第一笔记录')
                      : '较上次 ${WeightStats.delta(storage.latestDifference, jin)} $unit',
                  style: const TextStyle(
                    color: LavaTheme.lavaPink,
                    fontSize: 15,
                  ),
                ),
                if (latest != null && !isToday)
                  Text(
                    DateHelper.formatDateTime(latest.recordedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: LavaTheme.textMuted,
                    ),
                  ),
                SizedBox(height: math.max(70, bounds.maxHeight * 0.20)),
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '近 7 天',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '${WeightStats.delta(WeightStats.change(recent), jin)} $unit',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      LavaTrendChart(
                        records: recent,
                        height: 112,
                        useJin: jin,
                        compact: true,
                      ),
                    ],
                  ),
                ),
                if (storage.profile.targetWeightKg > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '目标 ${WeightStats.weight(storage.profile.targetWeightKg, jin)} $unit'
                      '   ·   累计 ${WeightStats.delta(storage.totalChange, jin)} $unit',
                      style: const TextStyle(
                        fontSize: 12,
                        color: LavaTheme.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: GlowingButton(
                    label: storage.isDemo ? '开始我的记录' : '记录体重',
                    icon: Icons.add,
                    width: 218,
                    onPressed: onRecord,
                  ),
                ),
                if (latest == null)
                  Center(
                    child: TextButton(
                      onPressed: () => storage.showDemo(),
                      child: const Text(
                        '先看看效果',
                        style: TextStyle(color: LavaTheme.textSecondary),
                      ),
                    ),
                  ),
                if (storage.loadError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GlowingButton(
                      label: storage.loadError!,
                      isSecondary: true,
                      onPressed: () async {
                        await storage.retryLoad();
                        if (context.mounted && storage.loadError != null) {
                          showNotice(context, storage.loadError!);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
