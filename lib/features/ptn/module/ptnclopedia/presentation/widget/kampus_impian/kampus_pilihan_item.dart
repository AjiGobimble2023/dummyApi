import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../../core/config/constant.dart';
import '../../../../../../../core/config/extensions.dart';
import '../../../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../entity/kampus_impian.dart';

class KampusPilihanItem extends StatelessWidget {
  final int pilihanKe;
  final bool isLoading;
  final bool isOrtu;
  final KampusImpian? kampusImpian;

  const KampusPilihanItem({
    Key? key,
    this.pilihanKe = 1,
    this.isLoading = false,
    this.isOrtu = false,
    this.kampusImpian,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 4,
      borderRadius:
          BorderRadius.circular((context.isMobile) ? 22 : context.dp(14)),
      padding: EdgeInsets.all(min(14, context.dp(7))),
      margin: EdgeInsets.only(bottom: min(20, context.dp(16))),
      onTap: (isLoading || isOrtu)
          ? null
          : () => Navigator.pushNamed(
                context,
                Constant.kRouteImpianPicker,
                arguments: {
                  'pilihanKe': pilihanKe,
                  'kampusPilihan': kampusImpian,
                },
              ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            (isLoading)
                ? ShimmerWidget.rounded(
                    width: min(68, context.dp(64)),
                    height: min(68, context.dp(64)),
                    borderRadius: BorderRadius.circular(context.dp(20)),
                  )
                : CustomImageNetwork(
                    'PTNPilihan$pilihanKe.png'.imgUrl,
                    width: min(68, context.dp(64)),
                    height: min(68, context.dp(64)),
                  ),
            const VerticalDivider(
              width: 14,
              indent: 10,
              endIndent: 10,
            ),
            Expanded(
              child: (!isLoading && kampusImpian == null)
                  ? Text('Pilih kampus impian kamu!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (isLoading)
                            ? ShimmerWidget.rounded(
                                width: (context.isMobile)
                                    ? context.dp(160)
                                    : context.dp(64),
                                height: min(16, context.dp(14)),
                                borderRadius: BorderRadius.circular(46))
                            : Text(
                                kampusImpian!.namaPTN,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall?.copyWith(
                                  color: context.hintColor,
                                ),
                              ),
                        if (isLoading) const SizedBox(height: 4),
                        (isLoading)
                            ? ShimmerWidget.rounded(
                                width: double.infinity,
                                height: min(20, context.dp(18)),
                                borderRadius: BorderRadius.circular(46))
                            : (pilihanKe == 1)
                                ? Hero(
                                    tag: 'impian-nama-ptn',
                                    transitionOnUserGestures: true,
                                    child: Text(
                                      kampusImpian!.namaJurusan,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.titleSmall,
                                    ),
                                  )
                                : Text(
                                    kampusImpian!.namaJurusan,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.titleSmall,
                                  ),
                        if (isLoading) const SizedBox(height: 4),
                        (isLoading)
                            ? ShimmerWidget.rounded(
                                width: (context.isMobile)
                                    ? context.dp(190)
                                    : context.dp(82),
                                height: min(16, context.dp(14)),
                                borderRadius: BorderRadius.circular(46))
                            : (pilihanKe == 1)
                                ? Hero(
                                    tag: 'impian-peminat-tampung',
                                    transitionOnUserGestures: true,
                                    child: Text(
                                      '${kampusImpian!.peminat} | ${kampusImpian!.tampung}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.bodySmall?.copyWith(
                                        color: context.hintColor,
                                      ),
                                    ),
                                  )
                                : Text(
                                    '${kampusImpian!.peminat} | ${kampusImpian!.tampung}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.bodySmall?.copyWith(
                                      color: context.hintColor,
                                    ),
                                  ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            (isLoading)
                ? ShimmerWidget.rounded(
                    width: min(24, context.dp(24)),
                    height: min(24, context.dp(24)),
                    borderRadius: BorderRadius.circular(8))
                : Icon(Icons.edit, color: context.primaryColor)
          ],
        ),
      ),
    );
  }
}
