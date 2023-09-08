import 'dart:math';

import 'package:flutter/material.dart';

import '../../../config/extensions.dart';
import '../../../config/global.dart';
import '../watermark/watermark_widget.dart';
import 'shimmer_widget.dart';

class ShimmerListTiles extends StatelessWidget {
  final bool isWatermarked;
  final bool shrinkWrap;
  final int jumlahItem;

  const ShimmerListTiles(
      {Key? key,
      this.isWatermarked = false,
      this.jumlahItem = 8,
      this.shrinkWrap = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isWatermarked
        ? WatermarkWidget(
            child: _buildListViewShimmer(context),
          )
        : _buildListViewShimmer(context);
  }

  ListView _buildListViewShimmer(BuildContext context) {
    return ListView.separated(
        shrinkWrap: shrinkWrap,
        padding: EdgeInsets.only(
          top: min(18, context.dp(14)),
          bottom: min(38, context.dp(30)),
        ),
        itemBuilder: (_, index) => ListTile(
              leading: ShimmerWidget.rounded(
                borderRadius: gDefaultShimmerBorderRadius,
                width: context.dp(50),
                height: context.dp(50),
              ),
              title: Padding(
                padding: EdgeInsets.only(
                  right: context.dw * ((context.isMobile) ? 0.3 : 0.2),
                ),
                child: ShimmerWidget.rounded(
                  borderRadius: gDefaultShimmerBorderRadius,
                  width: context.dp(80),
                  height: min(28, context.dp(18)),
                ),
              ),
              subtitle: ShimmerWidget.rounded(
                borderRadius: gDefaultShimmerBorderRadius,
                width: context.dp(180),
                height: min(20, context.dp(12)),
              ),
              trailing: ShimmerWidget.rounded(
                borderRadius: gDefaultShimmerBorderRadius,
                width: context.dp(32),
                height: context.dp(32),
              ),
            ),
        separatorBuilder: (_, index) => const Divider(),
        itemCount: jumlahItem);
  }
}
