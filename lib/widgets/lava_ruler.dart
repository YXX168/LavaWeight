import 'package:flutter/material.dart';
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
    this.minWeight = 30.0,
    this.maxWeight = 180.0,
    this.useJin = false,
  });

  @override
  State<LavaRuler> createState() => _LavaRulerState();
}

class _LavaRulerState extends State<LavaRuler> {
  late ScrollController _scrollController;
  static const double _tickWidth = 10.0; // pixels per 0.1 kg
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToWeight(widget.currentWeight, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant LavaRuler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWeight != widget.currentWeight && !_isUserScrolling) {
      _scrollToWeight(widget.currentWeight, animate: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToWeight(double weight, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final totalTicks = ((weight - widget.minWeight) * 10).round();
    final targetOffset = totalTicks * _tickWidth;
    if (animate) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  void _onScroll() {
    if (!_isUserScrolling) return;
    final offset = _scrollController.offset;
    final ticks = (offset / _tickWidth).round();
    final weight = widget.minWeight + (ticks / 10.0);
    final clamped = weight.clamp(widget.minWeight, widget.maxWeight);
    final rounded = double.parse(clamped.toStringAsFixed(1));
    if (rounded != widget.currentWeight) {
      widget.onWeightChanged(rounded);
    }
  }

  void _step(double delta) {
    final next = (widget.currentWeight + delta)
        .clamp(widget.minWeight, widget.maxWeight);
    final rounded = double.parse(next.toStringAsFixed(1));
    widget.onWeightChanged(rounded);
    _scrollToWeight(rounded, animate: true);
  }

  @override
  Widget build(BuildContext context) {
    final totalTicks = ((widget.maxWeight - widget.minWeight) * 10).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stepper buttons & Ruler Container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Minus 0.1 button
              _buildStepButton(
                icon: Icons.remove,
                onTap: () => _step(-0.1),
              ),
              const SizedBox(width: 8),

              // Horizontal Ruler Area
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final halfWidth = constraints.maxWidth / 2;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ruler ScrollView
                          NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollStartNotification) {
                                _isUserScrolling = true;
                              } else if (notification
                                  is ScrollUpdateNotification) {
                                _onScroll();
                              } else if (notification
                                  is ScrollEndNotification) {
                                _isUserScrolling = false;
                              }
                              return true;
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              padding:
                                  EdgeInsets.symmetric(horizontal: halfWidth),
                              itemCount: totalTicks + 1,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final isMajor = index % 10 == 0;
                                final isMedium = index % 5 == 0;
                                final weightVal =
                                    widget.minWeight + (index / 10.0);

                                return Container(
                                  width: _tickWidth,
                                  alignment: Alignment.bottomCenter,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isMajor)
                                        Text(
                                          widget.useJin
                                              ? (weightVal * 2)
                                                  .toStringAsFixed(0)
                                              : weightVal.toStringAsFixed(0),
                                          style: const TextStyle(
                                            color: LavaTheme.textMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: isMajor ? 2.0 : 1.0,
                                        height: isMajor
                                            ? 28.0
                                            : (isMedium ? 18.0 : 10.0),
                                        decoration: BoxDecoration(
                                          color: isMajor
                                              ? const Color(0xB3FFFFFF)
                                              : const Color(0x40FFFFFF),
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Center Glowing Needle Indicator
                          IgnorePointer(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Glowing Pointer Needle
                                Container(
                                  width: 3.5,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        LavaTheme.lavaPeach,
                                        LavaTheme.lavaPink,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: LavaTheme.lavaPink,
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),
              // Plus 0.1 button
              _buildStepButton(
                icon: Icons.add,
                onTap: () => _step(0.1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: LavaTheme.glassFill,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: LavaTheme.glassBorder, width: 1),
        ),
        child: Icon(icon, color: LavaTheme.textSecondary, size: 20),
      ),
    );
  }
}
