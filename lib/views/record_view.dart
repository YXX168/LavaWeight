import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/weight_record.dart';
import '../services/date_helper.dart';
import '../services/storage_service.dart';
import '../theme/lava_theme.dart';
import '../widgets/app_helpers.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';
import '../widgets/lava_background.dart';
import '../widgets/lava_ruler.dart';

class RecordView extends StatefulWidget {
  final StorageService storage;
  final WeightRecord? initialRecord;
  const RecordView({super.key, required this.storage, this.initialRecord});
  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  late double _weight;
  late DateTime _date;
  late bool _jin;
  late final TextEditingController _note;
  bool _saving = false;
  String? _mood;

  @override
  void initState() {
    super.initState();
    _weight =
        widget.initialRecord?.weightKg ??
        widget.storage.latestRecord?.weightKg ??
        70;
    _date = widget.initialRecord?.recordedAt ?? DateTime.now();
    _jin = widget.storage.profile.useJin;
    _mood = widget.initialRecord?.mood;
    _note = TextEditingController(text: widget.initialRecord?.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (time == null || !mounted) return;
    final selected = DateTime(
      day.year,
      day.month,
      day.day,
      time.hour,
      time.minute,
    );
    if (selected.isAfter(DateTime.now())) {
      showNotice(context, '请选择现在或过去的称重时间');
      return;
    }
    setState(() => _date = selected);
  }

  Future<void> _enterWeight() async {
    final controller = TextEditingController(
      text: (_weight * (_jin ? 2 : 1)).toStringAsFixed(1),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('输入体重（${_jin ? '斤' : 'kg'}）'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            helperText: _jin ? '40–600 斤' : '20–300 kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              final kg = value == null ? null : value / (_jin ? 2 : 1);
              if (kg == null || !kg.isFinite || kg < 20 || kg > 300) {
                showNotice(ctx, '请输入范围内的有效体重');
                return;
              }
              Navigator.pop(ctx, double.parse(kg.toStringAsFixed(1)));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
    // The dialog may still be completing its exit animation.
    Future<void>.delayed(const Duration(seconds: 1), controller.dispose);
    if (result != null && mounted) setState(() => _weight = result);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final record = WeightRecord(
        id:
            widget.initialRecord?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        weightKg: _weight,
        recordedAt: _date,
        note: _note.text.trim(),
        mood: _mood,
      );
      await widget.storage.saveRecord(record);
      if (mounted) {
        showNotice(context, '记录已保存');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) showNotice(context, '保存失败，请检查输入或稍后重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final label = DateUtils.isSameDay(_date, DateTime.now())
        ? '今天 · ${DateHelper.formatTime(_date)}'
        : DateHelper.formatShortDateTime(_date);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: PageBackdrop(
          image: 'record',
          motion: widget.storage.profile.motionEnabled,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: '返回',
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 21,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.initialRecord == null ? '记录体重' : '编辑记录',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _saving ? null : _pickDate,
                    icon: const Icon(Icons.schedule_outlined, size: 15),
                    label: Text(label),
                    style: TextButton.styleFrom(
                      foregroundColor: LavaTheme.textSecondary,
                      side: const BorderSide(color: LavaTheme.glassBorder),
                    ),
                  ),
                  SizedBox(
                    height: math.max(180, height * 0.37),
                    child: Center(
                      child: InkWell(
                        onTap: _saving ? null : _enterWeight,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    (_weight * (_jin ? 2 : 1)).toStringAsFixed(
                                      1,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 66,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _jin ? '斤' : 'kg',
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: LavaTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: _saving,
                    child: LavaRuler(
                      currentWeight: _weight,
                      useJin: _jin,
                      onWeightChanged: (value) =>
                          setState(() => _weight = value),
                    ),
                  ),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: const Color(0x887A3F83),
                      selectedForegroundColor: Colors.white,
                      side: const BorderSide(color: LavaTheme.glassBorder),
                    ),
                    segments: const [
                      ButtonSegment(value: false, label: Text('kg')),
                      ButtonSegment(value: true, label: Text('斤')),
                    ],
                    selected: {_jin},
                    onSelectionChanged: _saving
                        ? null
                        : (selection) => setState(() => _jin = selection.first),
                  ),
                  const SizedBox(height: 22),
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: _note,
                      enabled: !_saving,
                      maxLength: 500,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.edit_note_rounded, size: 23),
                        hintText: '今天感觉如何…',
                        counterText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: GlowingButton(
                      label: _saving ? '正在保存…' : '保存记录',
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
