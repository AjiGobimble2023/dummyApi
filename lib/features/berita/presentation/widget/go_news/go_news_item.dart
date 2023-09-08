import 'dart:math';

import 'package:flutter/material.dart';

import '../../../entity/berita.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';

class GoNewsItem extends StatelessWidget {
  final Berita berita;
  final bool isHome;

  const GoNewsItem({Key? key, required this.berita, this.isHome = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = (context.isMobile) ? context.dp(218) : context.dp(98);
    double height = (context.isMobile) ? context.dp(179) : context.dp(76);
    double imgHeight = (context.isMobile) ? context.dp(206) : context.dp(48);
    double imgHomeHeight =
        (context.isMobile) ? context.dp(123) : context.dp(48);

    return CustomCard(
      onTap: () => Navigator.pushNamed(
        context,
        Constant.kRouteDetailGoNews,
        arguments: {'berita': berita},
      ),
      padding: EdgeInsets.zero,
      elevation: isHome ? 0 : 12,
      margin: isHome
          ? EdgeInsets.only(left: min(24, context.dp(14)))
          : EdgeInsets.symmetric(
              vertical: context.dp(8),
              horizontal: context.dp(12),
            ),
      child: SizedBox(
        width: isHome ? width : double.infinity,
        height: isHome ? height : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              isHome ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Hero(
              tag: berita.id.beritaImageTag,
              transitionOnUserGestures: true,
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      (context.isMobile)
                          ? max(12, context.dp(12))
                          : context.dp(10),
                    ),
                  ),
                ),
                child: CustomImageNetwork.rounded(
                  berita.image,
                  width: isHome ? width : double.infinity,
                  height: isHome ? imgHomeHeight : imgHeight,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      (context.isMobile)
                          ? max(12, context.dp(12))
                          : context.dp(10),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: isHome
                  ? EdgeInsets.all((context.dw < 850)
                      ? min(10, context.dp(10))
                      : min(16, context.dp(10)))
                  : EdgeInsets.symmetric(
                      horizontal: min(16, context.dp(10)),
                      vertical: min(20, context.dp(12)),
                    ),
              child: isHome
                  ? Hero(
                      tag: berita.id.beritaTitleTag,
                      transitionOnUserGestures: true,
                      child: Text(
                        berita.title,
                        style: context.text.labelMedium,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor:
                            (context.dw < 850) ? context.textScale11 : null,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: berita.id.beritaTitleTag,
                          child: Text(
                            berita.title,
                            style: context.text.labelLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Hero(
                          tag: berita.id.beritaDateTag,
                          child: Text(
                            berita.date,
                            style: context.text.bodySmall?.copyWith(
                                fontSize: 10,
                                color: context.hintColor,
                                height: 1.75),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: context.dp(8)),
                        Hero(
                          tag: berita.id.beritaDescriptionTag,
                          child: Text(
                            berita.summary,
                            style: context.text.bodySmall,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
