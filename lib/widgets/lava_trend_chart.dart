import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weight_record.dart';
import '../theme/lava_theme.dart';

class LavaTrendChart extends StatefulWidget {
  final List<WeightRecord> records;
  final double height;
  final bool showPoints;

  const LavaTrendChart({
    super.key,
    required this.records,
    this.height = 220,
    this.showPoints = true,
  });

  @override
  State<LavaTrendChart> createState() => _LavaTrendChartState();
}

class _LavaTrendChartState extends State<LavaTrendChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            '暂无记录数据',
            style: TextStyle(color: LavaTheme.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    // Sort chronologically (oldest to newest) for chart plotting
    final sorted = List<WeightRecord>.from(widget.records)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onPanUpdate: (details) {
            _handleTouch(details.localPosition, width, sorted.length);
          },
          onTapDown: (details) {
            _handleTouch(details.localPosition, width, sorted.length);
          },
          onPanEnd: (_) => setState(() => _selectedIndex = null),
          onTapUp: (_) => setState(() => _selectedIndex = null),
          child: SizedBox(
            height: widget.height,
            width: width,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(width, widget.height),
                  painter: _ChartPainter(
                    records: sorted,
                    selectedIndex: _selectedIndex,
                  ),
                ),
                if (_selectedIndex != null &&
                    _selectedIndex! >= 0 &&
                    _selectedIndex! < sorted.length)
                  _buildTooltip(sorted[_selectedIndex!], width),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTouch(Offset localPosition, double totalWidth, int count) {
    if (count <= 1) return;
    const paddingHorizontal = 24.0;
    final chartWidth = totalWidth - (paddingHorizontal * 2);
    final dx = (localPosition.dx - paddingHorizontal).clamp(0.0, chartWidth);
    final ratio = dx / chartWidth;
    final index = (ratio * (count - 1)).round();
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  Widget _buildTooltip(WeightRecord record, double totalWidth) {
    final dateStr = DateFormat('MM月dd日 HH:mm').format(record.recordedAt);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xE62A0F38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LavaTheme.lavaPink, width: 1),
            boxShadow: LavaTheme.buttonGlowShadow,
          ),
          child: Text(
            '$dateStr · ${record.weightKg.toStringAsFixed(1)} kg',
            style: const TextStyle(
              color: LavaTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<WeightRecord> records;
  final int? selectedIndex;

  _ChartPainter({
    required this.records,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    const leftPadding = 24.0;
    const rightPadding = 24.0;
    const topPadding = 30.0;
    const bottomPadding = 32.0;

    final drawWidth = size.width - leftPadding - rightPadding;
    final drawHeight = size.height - topPadding - bottomPadding;

    // Determine min and max weights with padding
    double minW = records.first.weightKg;
    double maxW = records.first.weightKg;
    for (final r in records) {
      if (r.weightKg < minW) minW = r.weightKg;
      if (r.weightKg > maxW) maxW = r.weightKg;
    }

    if (maxW == minW) {
      maxW += 1.0;
      minW -= 1.0;
    } else {
      final range = maxW - minW;
      maxW += range * 0.15;
      minW -= range * 0.15;
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final textStyle = const TextStyle(
      color: LavaTheme.textMuted,
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );

    // Draw 3 horizontal grid lines (min, mid, max)
    for (int i = 0; i <= 2; i++) {
      final y = topPadding + (drawHeight / 2) * i;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final val = maxW - (maxW - minW) * (i / 2);
      final textSpan = TextSpan(
        text: '${val.toStringAsFixed(1)}',
        style: textStyle,
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
    }

    // Compute coordinate points
    final points = <Offset>[];
    for (int i = 0; i < records.length; i++) {
      final x = records.length == 1
          ? leftPadding + drawWidth / 2
          : leftPadding + (drawWidth / (records.length - 1)) * i;
      final normalizedY = (records[i].weightKg - minW) / (maxW - minW);
      final y = topPadding + drawHeight * (1.0 - normalizedY);
      points.add(Offset(x, y));
    }

    // Build smooth Bezier path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Fill Gradient under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, topPadding + drawHeight)
      ..lineTo(points.first.dx, topPadding + drawHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LavaTheme.chartFillGradient.createShader(
        Rect.fromLTWH(leftPadding, topPadding, drawWidth, drawHeight),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw Main glowing line
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [LavaTheme.lavaPeach, LavaTheme.lavaPink],
      ).createShader(
        Rect.fromLTWH(leftPadding, topPadding, drawWidth, drawHeight),
      )
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Endpoint Glowing Indicator
    final lastPoint = points.last;
    final glowPaint = Paint()
      ..color = LavaTheme.lavaPink.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 8, glowPaint);

    final dotPaint = Paint()
      ..color = LavaTheme.textPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 4, dotPaint);

    // If selected, draw crosshair
    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < points.length) {
      final selectedPoint = points[selectedIndex!];
      final crossHairPaint = Paint()
        ..color = LavaTheme.lavaPeach
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(selectedPoint.dx, topPadding),
        Offset(selectedPoint.dx, topPadding + drawHeight),
        crossHairPaint,
      );

      canvas.drawCircle(
        selectedPoint,
        6,
        Paint()..color = LavaTheme.lavaOrange,
      );
      canvas.drawCircle(
        selectedPoint,
        3,
        Paint()..color = LavaTheme.textPrimary,
      );
    }

    // X-Axis date labels (first and last)
    if (records.isNotEmpty) {
      final firstDate = DateFormat('MM.dd').format(records.first.recordedAt);
      final lastDate = DateFormat('MM.dd').format(records.last.recordedAt);

      final firstTp = TextPainter(
        text: TextSpan(text: firstDate, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      firstTp.paint(
        canvas,
        Offset(leftPadding, topPadding + drawHeight + 8),
      );

      final lastTp = TextPainter(
        text: TextSpan(text: lastDate, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      lastTp.paint(
        canvas,
        Offset(size.width - rightPadding - lastTp.width,
            topPadding + drawHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.records != records ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/weight_record.dart';
import '../theme/lava_theme.dart';

class LavaTrendChart extends StatefulWidget {
  final List<WeightRecord> records;
  final double height;
  final bool showPoints;

  const LavaTrendChart({
    super.key,
    required this.records,
    this.height = 220,
    this.showPoints = true,
  });

  @override
  State<LavaTrendChart> createState() => _LavaTrendChartState();
}

class _LavaTrendChartState extends State<LavaTrendChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            '暂无记录数据',
            style: TextStyle(color: LavaTheme.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    final sorted = List<WeightRecord>.from(widget.records)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onPanUpdate: (details) {
            _handleTouch(details.localPosition, width, sorted.length);
          },
          onTapDown: (details) {
            _handleTouch(details.localPosition, width, sorted.length);
          },
          onPanEnd: (_) => setState(() => _selectedIndex = null),
          onTapUp: (_) => setState(() => _selectedIndex = null),
          child: SizedBox(
            height: widget.height,
            width: width,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(width, widget.height),
                  painter: _ChartPainter(
                    records: sorted,
                    selectedIndex: _selectedIndex,
                  ),
                ),
                if (_selectedIndex != null &&
                    _selectedIndex! >= 0 &&
                    _selectedIndex! < sorted.length)
                  _buildTooltip(sorted[_selectedIndex!], width),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTouch(Offset localPosition, double totalWidth, int count) {
    if (count <= 1) return;
    const paddingHorizontal = 24.0;
    final chartWidth = totalWidth - (paddingHorizontal * 2);
    final dx = (localPosition.dx - paddingHorizontal).clamp(0.0, chartWidth);
    final ratio = dx / chartWidth;
    final index = (ratio * (count - 1)).round();
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  Widget _buildTooltip(WeightRecord record, double totalWidth) {
    final dateStr = DateFormat('MM月dd日 HH:mm').format(record.recordedAt);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xE62A0F38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LavaTheme.lavaPink, width: 1),
            boxShadow: LavaTheme.buttonGlowShadow,
          ),
          child: Text(
            '$dateStr · ${record.weightKg.toStringAsFixed(1)} kg',
            style: const TextStyle(
              color: LavaTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<WeightRecord> records;
  final int? selectedIndex;

  _ChartPainter({
    required this.records,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    const leftPadding = 24.0;
    const rightPadding = 24.0;
    const topPadding = 30.0;
    const bottomPadding = 32.0;

    final drawWidth = size.width - leftPadding - rightPadding;
    final drawHeight = size.height - topPadding - bottomPadding;

    // Determine min and max weights with padding
    double minW = records.first.weightKg;
    double maxW = records.first.weightKg;
    for (final r in records) {
      if (r.weightKg < minW) minW = r.weightKg;
      if (r.weightKg > maxW) maxW = r.weightKg;
    }

    if (maxW == minW) {
      maxW += 1.0;
      minW -= 1.0;
    } else {
      final range = maxW - minW;
      maxW += range * 0.15;
      minW -= range * 0.15;
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const textStyle = TextStyle(
      color: LavaTheme.textMuted,
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );

    // Draw 3 horizontal grid lines (min, mid, max)
    for (int i = 0; i <= 2; i++) {
      final y = topPadding + (drawHeight / 2) * i;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final val = maxW - (maxW - minW) * (i / 2);
      final textSpan = TextSpan(
        text: val.toStringAsFixed(1),
        style: textStyle,
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
    }

    // Compute coordinate points
    final points = <Offset>[];
    for (int i = 0; i < records.length; i++) {
      final x = records.length == 1
          ? leftPadding + drawWidth / 2
          : leftPadding + (drawWidth / (records.length - 1)) * i;
      final normalizedY = (records[i].weightKg - minW) / (maxW - minW);
      final y = topPadding + drawHeight * (1.0 - normalizedY);
      points.add(Offset(x, y));
    }

    // Build smooth Bezier path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Fill Gradient under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, topPadding + drawHeight)
      ..lineTo(points.first.dx, topPadding + drawHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LavaTheme.chartFillGradient.createShader(
        Rect.fromLTWH(leftPadding, topPadding, drawWidth, drawHeight),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw Main glowing line
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [LavaTheme.lavaPeach, LavaTheme.lavaPink],
      ).createShader(
        Rect.fromLTWH(leftPadding, topPadding, drawWidth, drawHeight),
      )
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Endpoint Glowing Indicator
    final lastPoint = points.last;
    final glowPaint = Paint()
      ..color = const Color(0x66FF2A85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 8, glowPaint);

    final dotPaint = Paint()
      ..color = LavaTheme.textPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 4, dotPaint);

    // If selected, draw crosshair
    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < points.length) {
      final selectedPoint = points[selectedIndex!];
      final crossHairPaint = Paint()
        ..color = LavaTheme.lavaPeach
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(selectedPoint.dx, topPadding),
        Offset(selectedPoint.dx, topPadding + drawHeight),
        crossHairPaint,
      );

      canvas.drawCircle(
        selectedPoint,
        6,
        Paint()..color = LavaTheme.lavaOrange,
      );
      canvas.drawCircle(
        selectedPoint,
        3,
        Paint()..color = LavaTheme.textPrimary,
      );
    }

    // X-Axis date labels (first and last)
    if (records.isNotEmpty) {
      final firstDate = DateFormat('MM.dd').format(records.first.recordedAt);
      final lastDate = DateFormat('MM.dd').format(records.last.recordedAt);

      final firstTp = TextPainter(
        text: TextSpan(text: firstDate, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      firstTp.paint(
        canvas,
        Offset(leftPadding, topPadding + drawHeight + 8),
      );

      final lastTp = TextPainter(
        text: TextSpan(text: lastDate, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      lastTp.paint(
        canvas,
        Offset(size.width - rightPadding - lastTp.width,
            topPadding + drawHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.records != records ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
