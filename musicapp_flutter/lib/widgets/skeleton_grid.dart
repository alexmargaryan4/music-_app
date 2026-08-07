import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme_extension.dart';

/// Shimmering placeholder grid shown while a search is in flight —
/// mirrors the web app's `.skeleton-card`.
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  const SkeletonGrid({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = colors.text0.withValues(alpha: 0.06);
    final highlight = colors.text0.withValues(alpha: 0.12);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 12, width: 100, color: Colors.white),
              const SizedBox(height: 6),
              Container(height: 10, width: 70, color: Colors.white),
            ],
          ),
        );
      },
    );
  }
}
