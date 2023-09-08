import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../provider/buku_provider.dart';
import '../../entity/buku.dart';
import '../../entity/bab_buku.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/screen/basic_screen.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../core/shared/widget/expanded/custom_expansion_tile.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class BabTeoriScreen extends StatefulWidget {
  // final String bab;
  final Buku buku;
  final String jenisBuku;
  final bool isRencanaPicker;

  const BabTeoriScreen({
    Key? key,
    required this.buku,
    required this.jenisBuku,
    required this.isRencanaPicker,
  }) : super(key: key);

  @override
  State<BabTeoriScreen> createState() => _BabTeoriScreenState();
}

class _BabTeoriScreenState extends State<BabTeoriScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late final Buku _buku = widget.buku;
  late final BukuProvider _bukuProvider = context.read<BukuProvider>();
  // late final String _subTitle = (widget.jenisBuku == 'teori')
  //     ? '${widget.jenisBuku.sentenceCase} ${_buku.kelengkapan} ${_buku.levelTeori}'
  //     : '${_buku.kelengkapan} ${_buku.levelTeori}';

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: '${widget.jenisBuku.sentenceCase} ${_buku.namaKelompokUjian}',
      subTitle: _buku.namaBuku,
      jumlahBarisTitle: 2,
      body: Selector<BukuProvider, List<BabUtamaBuku>>(
        selector: (_, buku) => buku.getListBabByKodeBuku(
          kodeBuku: _buku.kodeBuku,
          kelengkapan: _buku.kelengkapan,
          levelTeori: _buku.levelTeori,
        ),
        shouldRebuild: (previous, next) => next.any((bab) {
          bool shouldRebuild = next.length != previous.length;

          if (!shouldRebuild &&
              previous.any((prev) => prev.namaBabUtama == bab.namaBabUtama)) {
            var prevBab = previous
                .where((prev) => prev.namaBabUtama == bab.namaBabUtama)
                .first;

            shouldRebuild = bab.daftarBab.length != prevBab.daftarBab.length ||
                bab.daftarBab.any(
                  (subBab) {
                    if (prevBab.daftarBab.any(
                        (prevSubBab) => subBab.kodeBab == prevSubBab.kodeBab)) {
                      var temp = prevBab.daftarBab
                          .where((prevSubBab) =>
                              subBab.kodeBab == prevSubBab.kodeBab)
                          .first;

                      return subBab.idTeoriBab != temp.idTeoriBab ||
                          subBab.namaBab != temp.namaBab;
                    }
                    return false;
                  },
                );
          }

          return shouldRebuild;
        }),
        builder: (_, listBabSubBab, emptyWidget) => FutureBuilder<void>(
            future: _onRefreshBabTeori(false),
            builder: (context, snapshot) {
              final bool isLoadingBab = snapshot.connectionState ==
                      ConnectionState.waiting ||
                  context
                      .select<BukuProvider, bool>((buku) => buku.isLoadingBab);

              if (isLoadingBab) {
                return const ShimmerListTiles(isWatermarked: true);
              }

              var refreshWidget = CustomSmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefreshBabTeori,
                isDark: true,
                child: (listBabSubBab.isEmpty)
                    ? emptyWidget!
                    : _buildListBabBuku(listBabSubBab),
              );

              return (listBabSubBab.isEmpty)
                  ? refreshWidget
                  : WatermarkWidget(child: refreshWidget);
            }),
        child: BasicEmpty(
            isLandscape: !context.isMobile,
            imageUrl: 'ilustrasi_data_not_found.png'.illustration,
            title: 'Oops',
            subTitle: 'Bab Belum Tersedia',
            emptyMessage: 'Belum ada Bab pada Buku ${_buku.namaBuku}'),
      ),
    );
  }

  Future<void> _onRefreshBabTeori([bool refresh = true]) async {
    // Function load and refresh data
    await _bukuProvider
        .loadDaftarBab(
          isRefresh: refresh,
          kodeBuku: _buku.kodeBuku,
          kelengkapan: _buku.kelengkapan,
          levelTeori: _buku.levelTeori,
        )
        .onError((error, stackTrace) => _refreshController.refreshFailed())
        .then((_) => _refreshController.refreshCompleted());
    if (refresh) {
      _refreshController.refreshCompleted();
    }
  }

  void _navigateToTeoriContentScreen({
    required String namaBabUtama,
    required BabBuku babAktif,
    required List<BabBuku> daftarBab,
  }) {
    Map<String, dynamic> argument = {
      'daftarIsi': daftarBab,
      'kodeBab': babAktif.kodeBab,
      'jenisBuku': widget.jenisBuku,
      'namaBabUtama': namaBabUtama,
      'namaBabSubBab': babAktif.namaBab,
      'idTeoriBab': babAktif.idTeoriBab,
      'levelTeori': widget.buku.levelTeori,
      'kelengkapan': widget.buku.kelengkapan,
      'namaMataPelajaran': _buku.namaKelompokUjian,
      // 'listIdTeoriBabAwal': babAktif.listIdTeoriBab,
    };

    if (widget.isRencanaPicker) {
      argument.putIfAbsent(
        'idJenisProduk',
        () => ('jenisBuku' == 'rumus') ? 46 : 59,
      );
      argument.putIfAbsent(
        'keterangan',
        () => 'Belajar ${widget.jenisBuku} ${_buku.namaKelompokUjian} '
            'Bagian Bab ${babAktif.kodeBab} - ${babAktif.namaBab}.',
      );
      // argument.update(
      //   'listIdTeoriBabAwal',
      //   (listIdTeori) => (listIdTeori as List<String>).join(','),
      // );

      // Kirim data ke Rencana Belajar Editor
      Navigator.pop(context, argument);
      Navigator.pop(context, argument);
    } else {
      Navigator.pushNamed(
        context,
        Constant.kRouteBukuTeoriContent,
        arguments: argument,
      );
    }
  }

  Widget _buildListBabBuku(List<BabUtamaBuku> listBab) {
    int listBabLength = listBab.length;

    return (context.isMobile)
        ? ListView.separated(
            itemCount: listBabLength,
            padding: EdgeInsets.only(
              top: context.dp(8),
              bottom: context.dp(30),
            ),
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) => _buildExpansionBab(listBab, index),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              (listBabLength.isEven)
                  ? (listBabLength / 2).floor()
                  : (listBabLength / 2).floor() + 1,
              (index) => IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildExpansionBab(listBab, index * 2),
                    ),
                    VerticalDivider(indent: index == 0 ? 24 : 0),
                    (((index * 2) + 1) < listBabLength)
                        ? Expanded(
                            child: _buildExpansionBab(listBab, (index * 2) + 1),
                          )
                        : const Spacer(),
                  ],
                ),
              ),
            ),
          );
  }

  CustomExpansionTile _buildExpansionBab(
      List<BabUtamaBuku> listBab, int index) {
    return CustomExpansionTile(
      tilePadding: (context.isMobile)
          ? null
          : EdgeInsets.symmetric(
              horizontal: context.dp(12),
              vertical: context.dp(8),
            ),
      title: Text(
        listBab[index].namaBabUtama,
        style: context.text.titleSmall?.copyWith(fontFamily: 'Montserrat'),
      ),
      subtitle: Text(
        'Jumlah Bab dan Sub-Bab: ${listBab[index].daftarBab.length}',
        style: context.text.bodySmall?.copyWith(color: Colors.black54),
      ),
      children: List.generate(
        listBab[index].daftarBab.length,
        (i) => _buildItemBab(
          isLastItem: i == listBab[index].daftarBab.length - 1,
          babAktif: listBab[index].daftarBab[i],
          daftarBab: listBab[index].daftarBab,
          namaBabUtama: listBab[index].namaBabUtama,
        ),
      ),
    );
  }

  InkWell _buildItemBab({
    required bool isLastItem,
    required String namaBabUtama,
    required BabBuku babAktif,
    required List<BabBuku> daftarBab,
  }) {
    return InkWell(
      onTap: () => _navigateToTeoriContentScreen(
        babAktif: babAktif,
        namaBabUtama: namaBabUtama,
        daftarBab: daftarBab,
      ),
      child: Container(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          maxWidth: double.infinity,
          minHeight: (context.isMobile) ? context.dp(38) : context.dp(12),
          maxHeight: (context.isMobile) ? context.dp(60) : context.dp(38),
        ),
        margin: EdgeInsets.only(left: context.dp(24)),
        padding: EdgeInsets.only(
          top: min(12, context.dp(8)),
          right: min(28, context.dp(24)),
          bottom: min(12, context.dp(8)),
        ),
        decoration: (isLastItem && context.isMobile)
            ? null
            : BoxDecoration(
                border: Border(bottom: BorderSide(color: context.disableColor)),
              ),
        child: RichText(
          textAlign: TextAlign.left,
          textScaleFactor: context.textScale12,
          text: TextSpan(
            text: '(${babAktif.kodeBab}) ~ ',
            style: context.text.labelSmall?.copyWith(color: Colors.black54),
            semanticsLabel: 'Bab ${babAktif.kodeBab}',
            children: [
              TextSpan(
                text: babAktif.namaBab,
                style: context.text.bodyMedium,
                semanticsLabel: 'Bab ${babAktif.namaBab}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
