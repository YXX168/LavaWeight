import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/weight_record.dart';
import '../services/date_helper.dart';
import '../services/weight_stats.dart';
import '../theme/lava_theme.dart';

class LavaTrendChart extends StatefulWidget {
  final List<WeightRecord> records;
  final double height;
  final bool compact;
  final bool useJin;
  const LavaTrendChart({
    super.key,
    required this.records,
    this.height = 230,
    this.compact = false,
    this.useJin = false,
  });
  @override
  State<LavaTrendChart> createState() => _LavaTrendChartState();
}

class _LavaTrendChartState extends State<LavaTrendChart> {
  int? _selected;
  @override
  void didUpdateWidget(covariant LavaTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final rows = [...widget.records]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    if (rows.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            '这段时间还没有记录',
            style: TextStyle(color: LavaTheme.textSecondary, fontSize: 12),
          ),
        ),
      );
    }
    final unit = widget.useJin ? '斤' : 'kg';
    return Semantics(
      label:
          '体重趋势，${rows.length}条记录，'
          '最近${WeightStats.weight(rows.last.weightKg, widget.useJin)}$unit',
      child: LayoutBuilder(
        builder: (context, bounds) {
          void select(Offset position) {
            final positions = _xPositions(
              rows,
              bounds.maxWidth,
              widget.compact,
            );
            var closest = 0;
            for (var i = 1; i < positions.length; i++) {
              if ((positions[i] - position.dx).abs() <
                  (positions[closest] - position.dx).abs()) {
                closest = i;
              }
            }
            setState(() => _selected = closest);
          }

          final active = _selected == null || _selected! >= rows.length
              ? null
              : rows[_selected!];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => select(d.localPosition),
            onHorizontalDragUpdate: (d) => select(d.localPosition),
            child: SizedBox(
              height: widget.height,
              width: bounds.maxWidth,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(bounds.maxWidth, widget.height),
                    painter: _ChartPainter(
                      rows,
                      widget.useJin,
                      widget.compact,
                      _selected,
                    ),
                  ),
                  if (active != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: LavaTheme.backgroundAubergine,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            child: Text(
                              '${DateHelper.formatShortDateTime(active.recordedAt)} · '
                              '${WeightStats.weight(active.weightKg, widget.useJin)} $unit',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

List<double> _xPositions(List<WeightRecord> rows, double width, bool compact) {
  final left = compact ? 8.0 : 36.0;
  final span = math.max(1.0, width - left - 18);
  final start = rows.first.recordedAt.millisecondsSinceEpoch;
  final duration = rows.last.recordedAt.millisecondsSinceEpoch - start;
  return [
    for (final row in rows)
      duration == 0
          ? left + span / 2
          : left +
                span *
                    (row.recordedAt.millisecondsSinceEpoch - start) /
                    duration,
  ];
}

class _ChartPainter extends CustomPainter {
  final List<WeightRecord> rows;
  final bool jin;
  final bool compact;
  final int? selected;
  _ChartPainter(this.rows, this.jin, this.compact, this.selected);

  @override
  void paint(Canvas canvas, Size size) {
    final values = rows.map((r) => r.weightKg * (jin ? 2 : 1)).toList();
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final padding = math.max((high - low) * 0.18, jin ? 0.4 : 0.2);
    final min = low - padding;
    final max = high + padding;
    final left = compact ? 8.0 : 36.0;
    const top = 30.0;
    final bottom = size.height - 25;
    final xs = _xPositions(rows, size.width, compact);
    final points = [
      for (var i = 0; i < rows.length; i++)
        Offset(
          xs[i],
          top + (1 - (values[i] - min) / (max - min)) * (bottom - top),
        ),
    ];
    void label(String value, Offset point, {bool right = false}) {
      final painter = TextPainter(
        text: TextSpan(
          text: value,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 10,
            color: LavaTheme.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(right ? point.dx - painter.width : point.dx, point.dy),
      );
    }

    if (!compact) {
      for (var i = 0; i < 4; i++) {
        final y = top + (bottom - top) * i / 3;
        canvas.drawLine(
          Offset(left, y),
          Offset(size.width - 18, y),
          Paint()
            ..color = const Color(0x1AFFFFFF)
            ..strokeWidth = 0.7,
        );
        label(
          (max - (max - min) * i / 3).toStringAsFixed(1),
          Offset(left - 5, y - 6),
          right: true,
        );
      }
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    if (!compact && points.length > 1) {
      final fill = Path.from(path)
        ..lineTo(points.last.dx, bottom)
        ..lineTo(points.first.dx, bottom)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LavaTheme.chartFillGradient.createShader(
            Rect.fromLTWH(left, top, size.width - left, bottom - top),
          ),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = LavaTheme.lavaPink
        ..strokeWidth = compact ? 1.5 : 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        i == points.length - 1 ? 4 : 2,
        Paint()..color = LavaTheme.lavaPink,
      );
    }
    if (selected != null && selected! < points.length) {
      canvas.drawLine(
        Offset(points[selected!].dx, top),
        Offset(points[selected!].dx, bottom),
        Paint()
          ..color = const Color(0x80F4ABE5)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(
        points[selected!],
        5,
        Paint()..color = LavaTheme.textPrimary,
      );
    }
    label(
      DateHelper.formatShortDate(rows.first.recordedAt),
      Offset(left, bottom + 8),
    );
    if (rows.length > 1 &&
        !DateUtils.isSameDay(rows.first.recordedAt, rows.last.recordedAt)) {
      label(
        DateHelper.formatShortDate(rows.last.recordedAt),
        Offset(size.width - 18, bottom + 8),
        right: true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.rows != rows ||
      old.selected != selected ||
      old.jin != jin ||
      old.compact != compact;
}
