import 'dart:math';

import 'package:flutter/material.dart';

import '../../entity/sobat_tips_bab.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/loading/shimmer_list_tiles.dart';

class SobatTipsWidget extends StatelessWidget {
  final bool isBeliTeori;
  final Future<List<SobatTipsBab>> getSobatTips;

  const SobatTipsWidget(
      {Key? key, required this.getSobatTips, required this.isBeliTeori})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return FutureBuilder<List<SobatTipsBab>>(
      future: getSobatTips,
      builder: (_, snapshot) {
        final bool isLoading =
            snapshot.connectionState == ConnectionState.waiting;
        final List<SobatTipsBab> listSobatTips = snapshot.data ?? [];

        return Padding(
          padding: EdgeInsets.only(
            top: min(32, context.dp(24)),
            bottom: min(28, context.dp(20)),
            left: min(26, context.dp(18)),
            right: min(26, context.dp(18)),
          ),
          child: isLoading
              ? const ShimmerListTiles(shrinkWrap: true, jumlahItem: 2)
              : (listSobatTips.isEmpty || !isBeliTeori)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: (!isBeliTeori)
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          color: context.secondaryColor,
                          size: min(32, context.dp(32)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            textScaleFactor: context.textScale12,
                            text: TextSpan(
                                text: 'Sobat Tips\n',
                                style: context.text.titleMedium,
                                children: [
                                  TextSpan(
                                      text: (!isBeliTeori)
                                          ? 'Yaah, Kamu belum membeli produk buku Teori Sobat. Sobat Tips merupakan fitur yang menampilkan daftar teori yang berkaitan dengan soal untuk membantu kamu dalam belajar Sobat. Yuk beli produk buku Teori dari Ganesha Operation!'
                                          : 'Belum ada teori terkait dengan soal ini Sobat',
                                      style: context.text.labelMedium
                                          ?.copyWith(color: context.hintColor))
                                ]),
                          ),
                        ),
                      ],
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
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tips_and_updates_outlined,
                                color: context.secondaryColor,
                                size: min(32, context.dp(32)),
                              ),
                              const SizedBox(width: 8),
                              RichText(
                                textScaleFactor: context.textScale12,
                                text: TextSpan(
                                    text: 'Sobat Tips\n',
                                    style: context.text.titleMedium,
                                    children: [
                                      TextSpan(
                                          text: '~Teori terkait soal ini',
                                          style: context.text.labelMedium
                                              ?.copyWith(
                                                  color: context.hintColor))
                                    ]),
                                maxLines: 2,
                              ),
                            ],
                          ),
                          SizedBox(height: min(16, context.dp(12))),
                          ...listSobatTips
                              .map<Widget>(
                                (tips) => (tips.idTeoriBab.isEmpty)
                                    ? const SizedBox.shrink()
                                    : _buildBabButton(
                                        context,
                                        babAktif: tips,
                                        daftarBab: listSobatTips,
                                      ),
                              )
                              .toList()
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildBabButton(
    BuildContext context, {
    required SobatTipsBab babAktif,
    required List<SobatTipsBab> daftarBab,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.hintColor)),
      ),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(
            context, Constant.kRouteBukuTeoriContent,
            arguments: {
              'daftarIsi': daftarBab,
              'kodeBab': babAktif.kodeBab,
              'jenisBuku': 'teori',
              'namaBabSubBab': babAktif.namaBab,
              'idTeoriBab': babAktif.idTeoriBab,
              'levelTeori': babAktif.levelTeori,
              'kelengkapan': babAktif.kelengkapan,
              // 'listIdTeoriBabAwal': babAktif.listIdTeoriBab,
              'namaMataPelajaran': babAktif.mataPelajaran,
            }),
        style: TextButton.styleFrom(
          foregroundColor: context.hintColor,
          padding: EdgeInsets.symmetric(vertical: min(18, context.dp(12))),
          alignment: Alignment.centerLeft,
          textStyle: context.text.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.dp(16)),
          ),
        ),
        child: Text(
          '${babAktif.kodeBab} ${babAktif.namaBab}',
          textAlign: TextAlign.left,
          semanticsLabel: 'Bab dan Sub Bab Kisi-Kisi',
          style: context.text.bodyMedium,
        ),
      ),
    );
  }
}
