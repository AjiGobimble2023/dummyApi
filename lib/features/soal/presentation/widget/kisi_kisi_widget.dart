import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../module/timer_soal/entity/kisi_kisi.dart';
import '../../module/timer_soal/presentation/provider/tob_provider.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/loading/shimmer_list_tiles.dart';

class KisiKisiWidget extends StatelessWidget {
  final String kodePaket;

  const KisiKisiWidget({Key? key, required this.kodePaket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final List<KisiKisi> listKisiKisi =
        context.select<TOBProvider, List<KisiKisi>>(
            (tob) => tob.getListKisiKisiByKodePaket(kodePaket));

    return FutureBuilder<void>(
        future:
            context.read<TOBProvider>().getKisiKisiPaket(kodePaket: kodePaket),
        builder: (_, snapshot) {
          final bool isLoadingKisiKisi =
              snapshot.connectionState == ConnectionState.waiting;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: context.dp(24),
              right: context.dp(8),
            ),
            decoration: BoxDecoration(
                color: context.background,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24))),
            child: (isLoadingKisiKisi)
                ? const ShimmerListTiles(shrinkWrap: true, jumlahItem: 2)
                : (listKisiKisi.isEmpty || snapshot.hasError)
                    ? Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 12),
                      child: Text(snapshot.hasError
                          ? '${snapshot.error}'
                          : 'Belum ada kisi-kisi untuk Kode Paket $kodePaket'),
                    )
                    : Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 8,
                        radius: const Radius.circular(14),
                        child: ListView(
                          shrinkWrap: true,
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: context.dp(24),
                            right: context.dp(12),
                            left: context.dp(20),
                          ),
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.list_alt_rounded,
                                  color: context.tertiaryColor,
                                  size: context.dp(32),
                                ),
                                const SizedBox(width: 8),
                                RichText(
                                  textScaleFactor: context.textScale12,
                                  text: TextSpan(
                                      text: 'Kisi - Kisi\n',
                                      style: context.text.titleMedium,
                                      children: [
                                        TextSpan(
                                            text: '(Paket $kodePaket)',
                                            style: context.text.labelMedium
                                                ?.copyWith(
                                                    color: context.hintColor))
                                      ]),
                                  maxLines: 2,
                                )
                              ],
                            ),
                            SizedBox(height: context.dp(10)),
                            ...listKisiKisi
                                .map<Widget>(
                                  (kisi) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(kisi.kelompokUjian,
                                          textAlign: TextAlign.center,
                                          style: context.text.labelLarge),
                                      ...kisi.daftarBab.map<Widget>(
                                        (bab) => SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            '(${bab.initialMapel}) ~ ${bab.namaBab}',
                                            textAlign: TextAlign.left,
                                            semanticsLabel:
                                                'Bab dan Sub Bab Kisi-Kisi',
                                            style: context.text.bodyMedium
                                                ?.copyWith(
                                                    color: context.hintColor),
                                          ),
                                        ),
                                      ),
                                      Divider(height: context.dp(16))
                                    ],
                                  ),
                                )
                                .toList()
                          ],
                        ),
                      ),
          );
        });
  }
}
