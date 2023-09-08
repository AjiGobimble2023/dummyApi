import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../config/extensions.dart';
import '../image/custom_image_network.dart';

class BasicEmpty extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subTitle;
  final String emptyMessage;
  final Color? textColor;
  final bool shrink;
  final double? imageWidth;
  final bool isLandscape;

  const BasicEmpty({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subTitle,
    required this.emptyMessage,
    this.textColor,
    this.imageWidth,
    this.shrink = false,
    this.isLandscape = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      logger.log('BASIC_EMPTY-Build: Is Landscape >> $isLandscape');
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (isLandscape) ? context.dp(24) : context.dp(30),
      ),
      child: (isLandscape)
          ? Center(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildImageIllustration(context),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildTextStory(context),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: (shrink) ? MainAxisSize.min : MainAxisSize.max,
              children: [
                if (!shrink) const Spacer(),
                _buildImageIllustration(context),
                ..._buildTextStory(context),
                if (!shrink) const Spacer(),
              ],
            ),
    );
  }

  Widget _buildImageIllustration(BuildContext context) {
    double imgWidth = (context.dh.round() <= 683)
        ? min<double>(context.dp(200), 360)
        : min<double>(context.dp(296.0), 460);

    if (!context.isMobile && !isLandscape) {
      imgWidth = context.dp(120);
    }

    return (imageUrl.contains('https:') || imageUrl.contains('http:'))
        ? CustomImageNetwork(
            imageUrl,
            width: imageWidth ?? imgWidth,
            height: imageWidth ?? imgWidth,
            fit: BoxFit.contain,
          )
        : Image.asset(
            imageUrl,
            width: imageWidth ?? imgWidth,
            height: imageWidth ?? imgWidth,
            fit: BoxFit.contain,
          );
  }

  List<Widget> _buildTextStory(BuildContext context) {
    return [
      Padding(
        padding: EdgeInsets.only(
          top: (context.isMobile) ? context.dp(24) : context.dp(6),
          bottom: (context.isMobile) ? context.dp(10) : context.h(12),
        ),
        child: Text(
          title,
          style: context.text.headlineLarge?.copyWith(
              color: textColor ?? context.onBackground,
              fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: context.dp(8)),
        child: Text(
          subTitle,
          style: context.text.titleMedium
              ?.copyWith(color: textColor ?? context.onBackground),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
      Text(
        emptyMessage,
        style: context.text.bodyMedium?.copyWith(
          color: textColor?.withOpacity(0.54) ??
              context.onBackground.withOpacity(0.54),
        ),
        maxLines: 6,
        textAlign: TextAlign.center,
      ),
      if (!context.isMobile && !isLandscape) SizedBox(height: context.h(82))
    ];
  }
}
