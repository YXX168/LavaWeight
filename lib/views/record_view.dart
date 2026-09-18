import 'package:flutter/material.dart';
import '../models/weight_record.dart';
import '../services/date_helper.dart';
import '../services/storage_service.dart';
import '../theme/lava_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';
import '../widgets/lava_ruler.dart';
import '../widgets/mood_selector.dart';

class RecordView extends StatefulWidget {
  final StorageService storage;
  final WeightRecord? initialRecord;

  const RecordView({
    super.key,
    required this.storage,
    this.initialRecord,
  });

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  late double _weightKg;
  late DateTime _selectedDateTime;
  String? _selectedMood;
  final TextEditingController _noteController = TextEditingController();
  bool _useJin = false;

  @override
  void initState() {
    super.initState();
    _useJin = widget.storage.profile.useJin;
    if (widget.initialRecord != null) {
      _weightKg = widget.initialRecord!.weightKg;
      _selectedDateTime = widget.initialRecord!.recordedAt;
      _selectedMood = widget.initialRecord!.mood;
      _noteController.text = widget.initialRecord!.note ?? '';
    } else {
      _weightKg = widget.storage.latestRecord?.weightKg ?? 68.5;
      _selectedDateTime = DateTime.now();
      _selectedMood = 'great';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: LavaTheme.lavaPink,
              surface: LavaTheme.backgroundAubergine,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: LavaTheme.lavaPink,
                surface: LavaTheme.backgroundAubergine,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _save() {
    final record = WeightRecord(
      id: widget.initialRecord?.id ??
          'rec_${DateTime.now().millisecondsSinceEpoch}',
      weightKg: double.parse(_weightKg.toStringAsFixed(1)),
      recordedAt: _selectedDateTime,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      mood: _selectedMood,
    );

    widget.storage.saveRecord(record);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final displayWeight = _useJin ? _weightKg * 2 : _weightKg;
    final dateStr = '今天 · ${DateHelper.formatTime(_selectedDateTime)}';

    return Scaffold(
      backgroundColor: LavaTheme.background,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/record_lava.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Dark Ambient Vignette
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x2013071A), Color(0x7013071A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Main Interactive Content
          SafeArea(
            child: Column(
              children: [
                // Top Action Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: LavaTheme.textPrimary, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        '记录体重',
                        style: TextStyle(
                          color: LavaTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickDateTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: LavaTheme.glassFill,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: LavaTheme.glassBorderSubtle, width: 0.8),
                          ),
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              color: LavaTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 36),

                        // Large Numeric Weight Display (Centered on Lava Bubble)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              displayWeight.toStringAsFixed(1),
                              style: const TextStyle(
                                color: LavaTheme.textPrimary,
                                fontSize: 68,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.5,
                                shadows: [
                                  Shadow(
                                    color: Color(0x66FF2A85),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _useJin ? '斤' : 'kg',
                              style: const TextStyle(
                                color: LavaTheme.textSecondary,
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Unit Toggle (kg / 斤)
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: LavaTheme.glassFill,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: LavaTheme.glassBorderSubtle, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildUnitTab('kg', !_useJin),
                              _buildUnitTab('斤', _useJin),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tactile Horizontal Ruler
                        LavaRuler(
                          currentWeight: _weightKg,
                          useJin: _useJin,
                          onWeightChanged: (newWeight) {
                            setState(() => _weightKg = newWeight);
                          },
                        ),
                        const SizedBox(height: 32),

                        // Mood / Feeling Selector Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '此时此刻的状态',
                                  style: TextStyle(
                                    color: LavaTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                MoodSelector(
                                  selectedMood: _selectedMood,
                                  onMoodSelected: (mood) {
                                    setState(() => _selectedMood = mood);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Note Input Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: TextField(
                              controller: _noteController,
                              style: const TextStyle(
                                color: LavaTheme.textPrimary,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                hintText: '写点什么… 比如空腹称重、锻炼后等',
                                hintStyle: TextStyle(
                                  color: LavaTheme.textMuted,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Save Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GlowingButton(
                            label: '保存记录',
                            onPressed: _save,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _useJin = label == '斤');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? LavaTheme.lavaPink : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
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
}
