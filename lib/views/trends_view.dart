import 'package:flutter/material.dart';
import '../models/weight_record.dart';
import '../services/date_helper.dart';
import '../services/storage_service.dart';
import '../services/weight_stats.dart';
import '../theme/lava_theme.dart';
import '../widgets/app_helpers.dart';
import '../widgets/glass_card.dart';
import '../widgets/lava_background.dart';
import '../widgets/lava_trend_chart.dart';
import 'record_view.dart';

class TrendsView extends StatefulWidget {
  final StorageService storage;
  const TrendsView({super.key, required this.storage});
  @override
  State<TrendsView> createState() => _TrendsViewState();
}

class _TrendsViewState extends State<TrendsView> {
  TrendPeriod _period = TrendPeriod.month;
  @override
  Widget build(BuildContext context) {
    final storage = widget.storage;
    final jin = storage.profile.useJin;
    final unit = jin ? '斤' : 'kg';
    final rows = WeightStats.select(storage.records, _period, DateTime.now());
    final history = rows.reversed.toList();
    final caption = switch (_period) {
      TrendPeriod.week => '近 7 天变化',
      TrendPeriod.month => '近 30 天变化',
      TrendPeriod.all => '累计变化',
    };
    return PageBackdrop(
      image: 'trends',
      motion: storage.profile.motionEnabled,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '变化轨迹',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (storage.isDemo)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '演示数据',
                          style: TextStyle(
                            color: LavaTheme.lavaPink,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<TrendPeriod>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          backgroundColor: LavaTheme.glassFill,
                          selectedBackgroundColor: const Color(0x807A3F83),
                          selectedForegroundColor: Colors.white,
                          side: const BorderSide(color: LavaTheme.glassBorder),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: TrendPeriod.week,
                            label: Text('周'),
                          ),
                          ButtonSegment(
                            value: TrendPeriod.month,
                            label: Text('月'),
                          ),
                          ButtonSegment(
                            value: TrendPeriod.all,
                            label: Text('全部'),
                          ),
                        ],
                        selected: {_period},
                        onSelectionChanged: (selection) =>
                            setState(() => _period = selection.first),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      caption,
                      style: const TextStyle(
                        color: LavaTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${WeightStats.delta(WeightStats.change(rows), jin)} $unit',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
                      child: Column(
                        children: [
                          LavaTrendChart(
                            records: rows,
                            height: 225,
                            useJin: jin,
                          ),
                          const SizedBox(height: 22),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Metric(
                                    '已记录',
                                    '${WeightStats.days(rows)} 天',
                                  ),
                                ),
                                Expanded(
                                  child: Metric(
                                    '区间平均',
                                    '${WeightStats.weight(WeightStats.average(rows), jin)} $unit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '记录明细',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final record = history[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      key: ValueKey('history-${record.id}'),
                      borderRadius: 18,
                      blurSigma: 8,
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: storage.isDemo
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => RecordView(
                                          storage: storage,
                                          initialRecord: record,
                                        ),
                                      ),
                                    ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateHelper.formatDateTime(
                                      record.recordedAt,
                                    ),
                                    style: const TextStyle(
                                      color: LavaTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${WeightStats.weight(record.weightKg, jin)} $unit',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  if (record.note?.isNotEmpty ?? false)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        record.note!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: LavaTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (!storage.isDemo) ...[
                            IconButton(
                              tooltip: '编辑记录',
                              icon: const Icon(Icons.edit_outlined, size: 19),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => RecordView(
                                    storage: storage,
                                    initialRecord: record,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: '删除记录',
                              icon: const Icon(Icons.delete_outline, size: 19),
                              onPressed: () => _delete(record),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(WeightRecord record) async {
    if (!await confirmAction(
      context,
      title: '删除这笔记录？',
      message:
          '${DateHelper.formatDateTime(record.recordedAt)}\n'
          '${record.weightKg.toStringAsFixed(1)} kg，删除后无法撤销。',
      confirm: '删除',
    )) {
      return;
    }
    try {
      await widget.storage.deleteRecord(record.id);
    } catch (_) {
      if (mounted) showNotice(context, '删除失败，记录已保留，请重试');
    }
  }
}
