import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({super.key, this.width, this.height = 16, this.radius = 6});

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(GysColors.neutral100, GysColors.neutral200, _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Skeleton card matching the catalog product card shape.
class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: GysColors.neutral200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(aspectRatio: 1.3, child: SkeletonBox(height: double.infinity, radius: 13)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(height: 12),
                SizedBox(height: 6),
                SkeletonBox(width: 80, height: 10),
                SizedBox(height: 12),
                SkeletonBox(width: 100, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton row matching an order/list card.
class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(children: [SkeletonBox(width: 140, height: 14), Spacer(), SkeletonBox(width: 70, height: 18, radius: 10)]),
          SizedBox(height: 10),
          SkeletonBox(width: 180, height: 10),
          SizedBox(height: 10),
          SkeletonBox(width: 120, height: 14),
        ],
      ),
    );
  }
}
