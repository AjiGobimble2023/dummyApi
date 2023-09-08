import 'dart:developer' as logger;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../loading/shimmer_widget.dart';
import '../../../config/extensions.dart';

class CustomImageNetwork extends StatelessWidget {
  final String imgUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Alignment alignment;
  final bool shrinkShimmer;

  const CustomImageNetwork(
    this.imgUrl, {
    Key? key,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.shrinkShimmer = false,
  }) : super(key: key);

  final BorderRadius? borderRadius;
  const CustomImageNetwork.rounded(
    this.imgUrl, {
    Key? key,
    required this.borderRadius,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.shrinkShimmer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultWidth = shrinkShimmer ? context.dw * 0.3 : context.dw;
    double defaultHeight = shrinkShimmer ? context.dw * 0.2 : context.dw;

    CachedNetworkImage image = CachedNetworkImage(
      cacheKey: imgUrl,
      imageUrl: imgUrl,
      width: width,
      height: height,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit ?? BoxFit.cover,
      progressIndicatorBuilder: (_, url, downloadProgress) {
        return ShimmerWidget.rectangle(
            width: width ?? defaultWidth, height: height ?? defaultHeight);
      },
      errorWidget: (_, url, error) {
        if (kDebugMode) {
          logger.log('ERROR_CUSTOM_IMAGE_NETWORK: $url | $error');
        }
        return Container(
          width: width,
          height: height,
          color: context.surface,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/img/logo.webp',
            width:
                context.dp(min(width ?? defaultWidth, height ?? defaultHeight)),
          ),
        );
      },
    );

    return (borderRadius != null && borderRadius != BorderRadius.zero)
        ? ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: image,
          )
        : image;
  }
}
