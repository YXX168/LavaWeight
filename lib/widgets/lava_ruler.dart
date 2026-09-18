import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/lava_theme.dart';

class LavaRuler extends StatefulWidget {
  final double currentWeight;
  final ValueChanged<double> onWeightChanged;
  final double minWeight;
  final double maxWeight;
  final bool useJin;
  const LavaRuler({
    super.key,
    required this.currentWeight,
    required this.onWeightChanged,
    this.minWeight = 20,
    this.maxWeight = 300,
    this.useJin = false,
  });
  @override
  State<LavaRuler> createState() => _LavaRulerState();
}

class _LavaRulerState extends State<LavaRuler> {
  double _origin = 0;
  double _travel = 0;
  void _change(double value) {
    final rounded = double.parse(
      value.clamp(widget.minWeight, widget.maxWeight).toStringAsFixed(1),
    );
    if (rounded != widget.currentWeight) {
      HapticFeedback.selectionClick();
      widget.onWeightChanged(rounded);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Semantics(
        label: '体重刻度尺',
        value:
            '${(widget.currentWeight * (widget.useJin ? 2 : 1)).toStringAsFixed(1)}'
            '${widget.useJin ? '斤' : '公斤'}',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) {
            _origin = widget.currentWeight;
            _travel = 0;
          },
          onHorizontalDragUpdate: (d) {
            _travel += d.delta.dx;
            _change(_origin - _travel / 140);
          },
          child: SizedBox(
            height: 85,
            width: double.infinity,
            child: CustomPaint(
              painter: _RulerPainter(widget.currentWeight, widget.useJin),
            ),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: '减少体重',
            onPressed: () => _change(widget.currentWeight - 0.1),
            icon: const Icon(Icons.remove, size: 20),
          ),
          Text(
            widget.useJin ? '滑动微调 · 每格 0.2 斤' : '滑动微调 · 每格 0.1 kg',
            style: const TextStyle(
              fontSize: 11,
              color: LavaTheme.textSecondary,
            ),
          ),
          IconButton(
            tooltip: '增加体重',
            onPressed: () => _change(widget.currentWeight + 0.1),
            icon: const Icon(Icons.add, size: 20),
          ),
        ],
      ),
    ],
  );
}

class _RulerPainter extends CustomPainter {
  final double weight;
  final bool jin;
  _RulerPainter(this.weight, this.jin);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final tick = (weight * 10).round();
    final count = (size.width / 28).ceil() + 1;
    for (var i = -count; i <= count; i++) {
      final value = tick + i;
      if (value < 200 || value > 3000) continue;
      final x = center + i * 14.0;
      final major = value % 10 == 0;
      final length = major
          ? 33.0
          : value % 5 == 0
          ? 25.0
          : 17.0;
      canvas.drawLine(
        Offset(x, 40 - length),
        Offset(x, 40),
        Paint()
          ..color = const Color(0x779F8BA8)
          ..strokeWidth = 1,
      );
      if (major) {
        final text = TextPainter(
          text: TextSpan(
            text: (value / 10 * (jin ? 2 : 1)).toStringAsFixed(0),
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: LavaTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        text.paint(canvas, Offset(x - text.width / 2, 54));
      }
    }
    canvas.drawLine(
      Offset(center, 0),
      Offset(center, 44),
      Paint()
        ..color = LavaTheme.lavaPink
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RulerPainter old) =>
      old.weight != weight || old.jin != jin;
}
