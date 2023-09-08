import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/config/extensions.dart';
import '../../../model/capaian_detail_score.dart';
import '../../provider/capaian_provider.dart';
import 'detail_capaian_chart.dart';

class DetailCapaian extends StatefulWidget {
  const DetailCapaian({Key? key}) : super(key: key);

  @override
  State<DetailCapaian> createState() => _DetailCapaianState();
}

class _DetailCapaianState extends State<DetailCapaian> {
  // final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Selector<CapaianProvider, List<CapaianDetailScore>>(
      selector: (_, capaian) => capaian.capaianNilaiDetail,
      builder: (context, capaianNilaiDetail, child) {
        if (kDebugMode) {
          logger.log(
              'DETAIL_CAPAIAN_BOTTOMSHEET: Capaian Nilai Detail >> $capaianNilaiDetail');
        }
        if (capaianNilaiDetail.isEmpty) {
          return Container(
            width: double.infinity,
            height: context.dw * 0.2,
            color: context.background,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Center(
              child: Text(
                'Detail nilai tidak ditemukan',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        List<CapaianDetailScore> capaianDetail =
            capaianNilaiDetail.sublist(0, capaianNilaiDetail.length - 1);

        if (kDebugMode) {
          logger.log(
              'DETAIL_CAPAIAN_BOTTOMSHEET: Capaian Detail >> $capaianDetail');
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: DraggableScrollableSheet(
            snap: true,
            minChildSize: 0.3,
            initialChildSize: 0.5,
            snapSizes: const [0.3, 0.5, 0.8, 1],
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: context.background,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 18,
                  left: 14,
                  right: 14,
                ),
                children: [
                  Center(
                    child: Container(
                      width: min(240, context.dw / 3),
                      height: 8,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(64),
                      ),
                    ),
                  ),
                  Center(
                    child: Text('Detail Capaian',
                        style: context.text.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  const Divider(indent: 32, endIndent: 32),
                  const SizedBox(height: 16),
                  for (int i = 0; i < capaianDetail.length; i++)
                    ..._buildDetailItem(capaianDetail[i])
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDetailItem(CapaianDetailScore capaianDetail) {
    return [
      Row(
        children: [
          Text('Soal ${capaianDetail.label}',
              style: context.text.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Chip(
            label: Text('Skor: ${capaianDetail.score}'),
            backgroundColor: context.secondaryColor,
            labelStyle:
                context.text.labelLarge?.copyWith(color: context.onSecondary),
          ),
          const Expanded(child: Divider()),
        ],
      ),
      DetailCapaianChart(capaianDetail: capaianDetail),
      const SizedBox(height: 14),
    ];
  }
}
