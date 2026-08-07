import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme_extension.dart';

/// Two soft, slowly-drifting blurred glows behind the content — mirrors the
/// web app's `.ambient-glow` element. Wrap a screen's Scaffold body with
/// this so glass panels have something soft to show through.
class AmbientBackground extends StatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glowOpacity = isDark ? 0.13 : 0.22;

    return Container(
      color: colors.bg0,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return Stack(
                  children: [
                    Positioned(
                      top: -120 + (t * 40),
                      left: -80 + (t * 30),
                      child: _glowCircle(colors.accent, glowOpacity, 340),
                    ),
                    Positioned(
                      bottom: -100 - (t * 30),
                      right: -60 - (t * 20),
                      child: _glowCircle(colors.accent, glowOpacity, 280),
                    ),
                  ],
                );
              },
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  Widget _glowCircle(Color color, double opacity, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity * 0.5),
        ),
      ),
    );
  }
}
