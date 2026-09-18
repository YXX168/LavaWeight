import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/lava_theme.dart';

class LavaBackground extends StatefulWidget {
  final String image;
  final bool motion;
  const LavaBackground({super.key, required this.image, this.motion = true});

  @override
  State<LavaBackground> createState() => _LavaBackgroundState();
}

class _LavaBackgroundState extends State<LavaBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );
  bool _foreground = true;
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(covariant LavaBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMotion();
  }

  void _updateMotion() {
    _allowed =
        widget.motion &&
        _foreground &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (_allowed) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _updateMotion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        child: Image.asset(
          'assets/images/${widget.image}_lava.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) =>
              const ColoredBox(color: LavaTheme.background),
        ),
        builder: (context, child) {
          final wave = _allowed
              ? math.sin(_controller.value * 2 * math.pi)
              : 0.0;
          return Transform.scale(
            scale: 1.025 + wave * 0.012,
            child: Transform.translate(
              offset: Offset(wave * 3, wave * 4),
              child: child,
            ),
          );
        },
      ),
    ),
  );
}

class PageBackdrop extends StatelessWidget {
  final String image;
  final bool motion;
  final Widget child;
  const PageBackdrop({
    super.key,
    required this.image,
    required this.motion,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: LavaBackground(image: image, motion: motion),
      ),
      const Positioned.fill(
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x0916071D),
                  Color(0x0016071D),
                  Color(0x3516071D),
                ],
                stops: [0, 0.6, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
      child,
    ],
  );
}
