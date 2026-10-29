import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

/// Shimmering rounded box.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height = 16, this.radius = 10});
  final double? width;
  final double height, radius;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Shimmer.fromColors(
      baseColor: p.isDark ? const Color(0xFF1C2D35) : const Color(0xFFE6EEF1),
      highlightColor: p.isDark ? const Color(0xFF2A404A) : const Color(0xFFF7FAFB),
      child: Container(width: width, height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius))),
    );
  }
}

/// Card-shaped placeholder list. [variant]: 'doctor' | 'tile' | 'card'.
class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 5, this.itemHeight = 132, this.padding = const EdgeInsets.all(AppSpacing.screenH), this.shrink = false, this.variant = 'card'});
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;
  final bool shrink;
  final String variant;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return ListView.separated(
      padding: padding,
      shrinkWrap: shrink,
      physics: shrink ? const NeverScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => Container(
        height: itemHeight,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rLg, border: Border.all(color: p.border)),
        child: Row(children: [
          ShimmerBox(width: itemHeight - 28 > 84 ? 84 : itemHeight - 28, height: itemHeight - 28 > 84 ? 84 : itemHeight - 28, radius: 22),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRect(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  ShimmerBox(width: 150, height: 16),
                  SizedBox(height: 10),
                  ShimmerBox(width: 100, height: 12),
                  SizedBox(height: 10),
                  ShimmerBox(height: 12),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
