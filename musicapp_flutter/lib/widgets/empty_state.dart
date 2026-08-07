import 'package:flutter/material.dart';
import '../theme/app_theme_extension.dart';

/// Centered icon + message shown when a list has nothing to display yet —
/// mirrors the web app's `.empty-state`.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.text0.withValues(alpha: 0.06),
              ),
              child: Icon(icon, size: 30, color: colors.text2),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: colors.text1, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
