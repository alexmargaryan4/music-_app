import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme_extension.dart';

/// A frosted-glass container, the core visual building block of the app —
/// mirrors the web app's `.glass` / `.glass-strong` CSS classes (blurred,
/// semi-transparent surface with a soft border and a subtle top highlight).
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool strong;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.strong = false,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final alpha = strong ? colors.glassAlphaStrong : colors.glassAlpha;
    final blurSigma = strong ? 22.0 : 16.0;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: colors.glassTint.withValues(alpha: alpha),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: colors.text0.withValues(alpha: 0.08),
                    width: 1,
                  ),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
