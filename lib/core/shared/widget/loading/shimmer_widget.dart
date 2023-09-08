import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../config/extensions.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;

  const ShimmerWidget(
      {Key? key,
        required this.width,
        required this.height,
        this.borderRadius,
        this.shape = BoxShape.rectangle})
      : super(key: key);

  const ShimmerWidget.rectangle(
      {Key? key, required this.width,
        required this.height,
        this.borderRadius,
        this.shape = BoxShape.rectangle}) : super(key: key);

  const ShimmerWidget.rounded(
      {Key? key, required this.width,
        required this.height,
        required this.borderRadius,
        this.shape = BoxShape.rectangle}) : super(key: key);

  const ShimmerWidget.circle(
      {Key? key, required this.width,
        required this.height,
        this.borderRadius,
        this.shape = BoxShape.circle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.onSurface.withOpacity(0.4),
      highlightColor: context.onSurface.withOpacity(0.2),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.onSurface.withOpacity(0.4),
          shape: shape,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}