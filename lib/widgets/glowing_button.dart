import 'package:flutter/material.dart';
import '../theme/lava_theme.dart';

class GlowingButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final bool isSecondary;

  const GlowingButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.height = 54.0,
    this.width,
    this.isSecondary = false,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            gradient: widget.isSecondary ? null : LavaTheme.buttonGradient,
            color: widget.isSecondary ? LavaTheme.glassFill : null,
            border: Border.all(
              color: widget.isSecondary
                  ? LavaTheme.glassBorder
                  : const Color(0x66FFFFFF),
              width: 1.2,
            ),
            boxShadow: widget.isSecondary
                ? LavaTheme.cardShadow
                : LavaTheme.buttonGlowShadow,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: LavaTheme.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: LavaTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
