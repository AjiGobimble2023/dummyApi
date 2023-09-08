import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/feed.dart';

class FeedBodyWidget extends StatelessWidget {
  const FeedBodyWidget({
    Key? key,
    required this.feed,
    this.width,
    this.height,
    required this.isComment,
  }) : super(key: key);

  /// [feed] merupakan variable yang berisi data
  /// dari Class Feed yang teridiri dari (feedId, creatorId, creatorName,
  /// creatorRole, image, content, status, isLike, totalLike dan date)
  final Feed feed;

  /// [isCommment] merupakan variable untuk
  /// membedakan tampilan widget dari FeedActionAndCaption
  final bool isComment;

  /// Kumpulan variable Size
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(
        (context.isMobile)
            ? context.pd
            : isComment
                ? context.pd
                : context.pd / 2,
      ),
      width: (context.isMobile)
          ? width ?? context.dw - (context.pd * 4)
          : (context.dw - context.dp(132) - (context.pd * 4)),
      height: (context.isMobile)
          ? height ?? context.dw - (context.pd * 4)
          : context.dw - context.dp(132) - (context.pd * 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: feed.image!,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, url) {
            return Shimmer.fromColors(
              baseColor: context.onSurface.withOpacity(0.4),
              highlightColor: context.onSurface.withOpacity(0.2),
              child: const SizedBox(
                height: 365,
                width: double.infinity,
              ),
            );
          },
        ),
      ),
    );
  }
}
