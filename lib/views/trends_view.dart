import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weight_record.dart';
import '../services/storage_service.dart';
import '../theme/lava_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/lava_trend_chart.dart';

class TrendsView extends StatefulWidget {
  final StorageService storage;

  const TrendsView({super.key, required this.storage});

  @override
  State<TrendsView> createState() => _TrendsViewState();
}

class _TrendsViewState extends State<TrendsView> {
  int _selectedPeriod = 1; // 0: 周, 1: 月, 2: 全部

  List<WeightRecord> _getFilteredRecords() {
    final all = widget.storage.records;
    if (all.isEmpty) return [];

    final now = DateTime.now();
    if (_selectedPeriod == 0) {
      final threshold = now.subtract(const Duration(days: 7));
      final filtered =
          all.where((r) => r.recordedAt.isAfter(threshold)).toList();
      return filtered.isNotEmpty ? filtered : all.take(7).toList();
    } else if (_selectedPeriod == 1) {
      final threshold = now.subtract(const Duration(days: 30));
      final filtered =
          all.where((r) => r.recordedAt.isAfter(threshold)).toList();
      return filtered.isNotEmpty ? filtered : all.take(30).toList();
    } else {
      return all;
    }
  }

  double? _calculatePeriodDiff(List<WeightRecord> records) {
    if (records.length < 2) return null;
    final sorted = List<WeightRecord>.from(records)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final diff = sorted.last.weightKg - sorted.first.weightKg;
    return double.parse(diff.toStringAsFixed(1));
  }

  double _calculateAverage(List<WeightRecord> records) {
    if (records.isEmpty) return 0.0;
    final sum = records.fold<double>(0.0, (prev, r) => prev + r.weightKg);
    return double.parse((sum / records.length).toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredRecords();
    final periodDiff = _calculatePeriodDiff(filtered);
    final avgWeight = _calculateAverage(filtered);

    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/trends_lava.png',
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
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '变化轨迹',
                          style: TextStyle(
                            color: LavaTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '每一次记录，都算数',
                          style: TextStyle(
                            color: LavaTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // Segmented Period Pills (周 / 月 / 全部)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: LavaTheme.glassFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: LavaTheme.glassBorderSubtle),
                      ),
                      child: Row(
                        children: [
                          _buildPeriodTab('周', 0),
                          _buildPeriodTab('月', 1),
                          _buildPeriodTab('全部', 2),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Change Stat
                Text(
                  _selectedPeriod == 0
                      ? '本周变化'
                      : (_selectedPeriod == 1 ? '本月变化' : '总变化'),
                  style: const TextStyle(
                    color: LavaTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      periodDiff != null
                          ? '${periodDiff > 0 ? '+' : ''}${periodDiff.toStringAsFixed(1)}'
                          : '--',
                      style: const TextStyle(
                        color: LavaTheme.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'kg',
                      style: TextStyle(
                        color: LavaTheme.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Main Trend Chart Card
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '体重波动趋势',
                              style: TextStyle(
                                color: LavaTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '拖动查看详情',
                              style: TextStyle(
                                color: Color(0xCC8F80A0),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      LavaTrendChart(
                        records: filtered,
                        height: 200,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Insight Summary Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: LavaTheme.lavaPeach,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '记录，让变化有迹可循',
                            style: TextStyle(
                              color: LavaTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInsightItem(
                            '已记录天数',
                            '${widget.storage.records.length} 天',
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: LavaTheme.glassBorderSubtle,
                          ),
                          _buildInsightItem(
                            '区间平均',
                            '${avgWeight.toStringAsFixed(1)} kg',
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: LavaTheme.glassBorderSubtle,
                          ),
                          _buildInsightItem(
                            '打卡达成率',
                            '${((widget.storage.records.length / 30.0) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // History Records List Header
                const Text(
                  '历史明细',
                  style: TextStyle(
                    color: LavaTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // History Items
                ...widget.storage.records.take(15).map((record) {
                  return _buildHistoryItem(record);
                }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? LavaTheme.lavaPink : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? LavaTheme.textPrimary : LavaTheme.textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildInsightItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: LavaTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: LavaTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(WeightRecord record) {
    final dateStr = DateFormat('MM月dd日 EEEE · HH:mm', 'zh_CN')
        .format(record.recordedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: LavaTheme.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LavaTheme.glassBorderSubtle, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: const TextStyle(color: LavaTheme.textMuted, fontSize: 12),
              ),
              if (record.note != null && record.note!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  record.note!,
                  style: const TextStyle(
                    color: LavaTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
          Row(
            children: [
              Text(
                record.weightKg.toStringAsFixed(1),
                style: const TextStyle(
                  color: LavaTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'kg',
                style: TextStyle(color: LavaTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: LavaTheme.textMuted, size: 18),
                onPressed: () => _confirmDelete(record),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(WeightRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LavaTheme.backgroundAubergine,
        title: const Text('删除记录',
            style: TextStyle(color: LavaTheme.textPrimary)),
        content: Text(
          '确定删除 ${record.weightKg.toStringAsFixed(1)} kg 的这条记录吗？',
          style: const TextStyle(color: LavaTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('取消', style: TextStyle(color: LavaTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              widget.storage.deleteRecord(record.id);
              Navigator.pop(ctx);
            },
            child:
                const Text('删除', style: TextStyle(color: LavaTheme.lavaPink)),
          ),
        ],
      ),
    );
  }
}
