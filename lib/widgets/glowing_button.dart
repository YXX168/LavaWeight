import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/lava_theme.dart';

class GlowingButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final double? width;
  final bool isSecondary;
  const GlowingButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.height = 54,
    this.width,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onPressed == null ? 0.5 : 1,
    child: Container(
      width: width,
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: isSecondary ? null : LavaTheme.buttonGlowShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isSecondary
                    ? LavaTheme.glassBorder
                    : const Color(0xCCEAB4E0),
              ),
              gradient: LinearGradient(
                colors: isSecondary
                    ? [const Color(0x224C2A50), const Color(0x18362140)]
                    : [
                        const Color(0xBDB14B8D),
                        const Color(0x686B2057),
                        const Color(0xA38B326B),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 21),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
