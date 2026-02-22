import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}