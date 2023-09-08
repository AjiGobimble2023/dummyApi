import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../../core/config/extensions.dart';
import '../../../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../entity/kampus_impian.dart';

/// [kampusRiwayat] null sama dengan loading.
class RiwayatPilihan extends StatelessWidget {
  // final bool isLoading;
  final KampusImpian? kampusRiwayat;

  const RiwayatPilihan({
    Key? key,
    // this.isLoading = false,
    this.kampusRiwayat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 4,
      borderRadius:
          BorderRadius.circular((context.isMobile) ? 24 : context.dp(16)),
      padding: EdgeInsets.all(min(18, context.dp(10))),
      margin: EdgeInsets.only(bottom: min(20, context.dp(16))),
      child: Row(
        children: [
          (kampusRiwayat == null)
              ? ShimmerWidget.rounded(
                  width: min(36, context.dp(32)),
                  height: min(120, context.dp(91)),
                  borderRadius: BorderRadius.circular(120),
                )
              : RotatedBox(
                  quarterTurns: 3,
                  child: Container(
                    height: min(36, context.dp(32)),
                    padding: const EdgeInsets.only(
                      top: 4,
                      left: 4,
                      bottom: 4,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.tertiaryColor,
                      borderRadius: BorderRadius.circular(120),
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(-1, -1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: context.tertiaryColor.withOpacity(0.42)),
                        BoxShadow(
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: context.tertiaryColor.withOpacity(0.42))
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded, color: context.onTertiary),
                        Text(
                          ' Pilihan ${kampusRiwayat?.pilihanKe}',
                          style: context.text.labelMedium
                              ?.copyWith(color: context.onTertiary),
                        )
                      ],
                    ),
                  ),
                ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: (kampusRiwayat == null)
                      ? EdgeInsets.only(
                          left: (context.isMobile) ? 10 : 16,
                          bottom: 4,
                        )
                      : EdgeInsets.only(left: (context.isMobile) ? 10 : 16),
                  child: (kampusRiwayat == null)
                      ? ShimmerWidget.rounded(
                          width: (context.isMobile)
                              ? context.dp(180)
                              : context.dp(72),
                          height: min(16, context.dp(14)),
                          borderRadius: BorderRadius.circular(46))
                      : Text(
                          kampusRiwayat!.namaPTN,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: context.hintColor,
                          ),
                        ),
                ),
                Padding(
                  padding: (kampusRiwayat == null)
                      ? EdgeInsets.only(
                          left: (context.isMobile) ? 10 : 16,
                          bottom: 4,
                        )
                      : EdgeInsets.only(left: (context.isMobile) ? 10 : 16),
                  child: (kampusRiwayat == null)
                      ? ShimmerWidget.rounded(
                          width: (context.isMobile)
                              ? context.dp(260)
                              : context.dp(120),
                          height: min(20, context.dp(18)),
                          borderRadius: BorderRadius.circular(46))
                      : Text(
                          kampusRiwayat!.namaJurusan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall,
                        ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: (context.isMobile) ? 10 : 16),
                  child: (kampusRiwayat == null)
                      ? ShimmerWidget.rounded(
                          width: (context.isMobile)
                              ? context.dp(220)
                              : context.dp(140),
                          height: min(16, context.dp(14)),
                          borderRadius: BorderRadius.circular(46))
                      : Text(
                          '${kampusRiwayat?.peminat} | ${kampusRiwayat?.tampung}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: context.hintColor,
                          ),
                        ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.only(left: (context.isMobile) ? 10 : 16),
                  child: (kampusRiwayat == null)
                      ? ShimmerWidget.rounded(
                          width: (context.isMobile)
                              ? context.dp(160)
                              : context.dp(64),
                          height: min(14, context.dp(12)),
                          borderRadius: BorderRadius.circular(46))
                      : Text(
                          'Diubah pada: ${kampusRiwayat!.tanggalPilih.hoursMinutesDDMMMYYYY}',
                          style: context.text.labelSmall,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
