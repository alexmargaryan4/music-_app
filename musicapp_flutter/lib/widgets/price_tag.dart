import 'package:flutter/material.dart';
import '../theme/app_theme_extension.dart';

/// Small pill badge showing a track's price, filled with the accent color
/// — mirrors the web app's `.price-tag` class.
class PriceTag extends StatelessWidget {
  final String text;
  const PriceTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.accentContrast,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
