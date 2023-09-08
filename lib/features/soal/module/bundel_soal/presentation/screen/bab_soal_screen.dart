// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../entity/bundel_soal.dart';
import '../provider/bundel_soal_provider.dart';
import '../../entity/bab_soal.dart';
import '../../../../model/detail_hasil_model.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../../core/shared/widget/expanded/custom_expansion_tile.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class BabSoalScreen extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final String idBundel;
  final String kodeTOB;
  final String kodePaket;
  final String namaKelompokUjian;
  final int jumlahSoal;
  final bool isRencanaPicker;

  const BabSoalScreen({
    Key? key,
    required this.namaKelompokUjian,
    required this.jumlahSoal,
    required this.kodeTOB,
    required this.kodePaket,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.idBundel,
    required this.isRencanaPicker,
  }) : super(key: key);

  @override
  State<BabSoalScreen> createState() => _BabSoalScreenState();
}

class _BabSoalScreenState extends State<BabSoalScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late final BundelSoalProvider _bundelSoalProvider =
      context.read<BundelSoalProvider>();

  List<DetailHasilModel>? listDetailHasil;
  String? idSekolahKelas;

  @override
  void initState() {
    idSekolahKelas =
        context.read<AuthOtpProvider>().idSekolahKelas.value ?? '14';
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: widget.namaKelompokUjian,
      subTitle: 'Jumlah Soal: ${widget.jumlahSoal}',
      jumlahBarisTitle: 2,
      body: Selector<BundelSoalProvider, List<BabUtamaSoal>>(
        selector: (_, bundelSoal) =>
            bundelSoal.getListBabByIdBundel(widget.idBundel),
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

                      return subBab.idBundel != temp.idBundel ||
                          subBab.namaBab != temp.namaBab;
                    }
                    return false;
                  },
                );
          }

          return shouldRebuild;
        }),
        builder: (_, listBabSubBab, emptyWidget) => FutureBuilder<void>(
            future: _onRefreshBabSoal(false),
            builder: (context, snapshot) {
              final bool isLoadingBab =
                  snapshot.connectionState == ConnectionState.waiting ||
                      context.select<BundelSoalProvider, bool>(
                          (bundel) => bundel.isLoadingBab);

              if (isLoadingBab) {
                return const ShimmerListTiles(isWatermarked: true);
              }

              var refreshWidget = CustomSmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefreshBabSoal,
                isDark: true,
                child: (listBabSubBab.isEmpty)
                    ? emptyWidget!
                    : _buildListBabSoal(context, listBabSubBab),
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
            emptyMessage:
                'Belum ada Bab pada bundel ${widget.idBundel}. ${widget.namaKelompokUjian}'),
      ),
    );
  }

  Future<void> _onRefreshBabSoal([bool refresh = true]) async {
    // Function load and refresh data
    await _bundelSoalProvider
        .getDaftarBabSoal(isRefresh: refresh, idBundel: widget.idBundel)
        .onError((error, stackTrace) => _refreshController.refreshFailed())
        .then((_) => _refreshController.refreshCompleted());
    if (refresh) {
      _refreshController.refreshCompleted();
    }
  }

  void _navigateToSoalBasicScreen(
      {required String kodeBab, required String namaBab}) {
    Map<String, dynamic> argument = {
      'idJenisProduk': widget.idJenisProduk,
      'namaJenisProduk': widget.namaJenisProduk,
      'diBukaDariRoute': Constant.kRouteBabBukuSoalScreen,
      'kodeTOB': widget.kodeTOB,
      'kodePaket': widget.kodePaket,
      'idBundel': widget.idBundel,
      'kodeBab': kodeBab,
      'namaBab': namaBab,
      'namaKelompokUjian': widget.namaKelompokUjian,
      'isPaket': false,
      'isSimpan': true,
      'isBisaBookmark': true
    };
    if (widget.isRencanaPicker) {
      argument.putIfAbsent(
        'keterangan',
        () => 'Mengerjakan ${widget.namaJenisProduk.replaceFirst('e-', '')} '
            '${widget.namaKelompokUjian}(${widget.kodePaket}) Bagian Bab $kodeBab - $namaBab.',
      );
      // Kirim data ke Rencana Belajar Editor
      Navigator.pop(context, argument);
      Navigator.pop(context, argument);
    } else {
      argument.putIfAbsent('opsiUrut', () => OpsiUrut.bab);
      Navigator.pushNamed(context, Constant.kRouteSoalBasicScreen,
          arguments: argument);
    }
  }

  Widget _buildListBabSoal(BuildContext context, List<BabUtamaSoal> listBab) {
    int listBabLength = listBab.length;

    return (context.isMobile)
        ? ListView.separated(
            itemCount: listBabLength,
            separatorBuilder: (_, __) => const Divider(),
            physics: const NeverScrollableScrollPhysics(),
            padding:
                EdgeInsets.only(top: context.dp(8), bottom: context.dp(30)),
            itemBuilder: (_, index) =>
                _buildExpansionBab(listBab, index, context),
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
                      child: _buildExpansionBab(listBab, index * 2, context),
                    ),
                    VerticalDivider(indent: index == 0 ? 24 : 0),
                    (((index * 2) + 1) < listBabLength)
                        ? Expanded(
                            child: _buildExpansionBab(
                                listBab, (index * 2) + 1, context),
                          )
                        : const Spacer(),
                  ],
                ),
              ),
            ),
          );
  }

  CustomExpansionTile _buildExpansionBab(
      List<BabUtamaSoal> listBab, int index, BuildContext context) {
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
      children: listBab[index]
          .daftarBab
          .map<Widget>(
            (dataBab) => _buildBabItem(dataBab, context),
          )
          .toList(),
    );
  }

  InkWell _buildBabItem(BabSoal dataBab, BuildContext context) {
    return InkWell(
      onTap: () async {
        _navigateToSoalBasicScreen(
            kodeBab: dataBab.kodeBab, namaBab: dataBab.namaBab);
      },
      child: Container(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          maxWidth: double.infinity,
          minHeight: (context.isMobile) ? context.dp(38) : context.dp(12),
          maxHeight: (context.isMobile) ? context.dp(60) : context.dp(38),
        ),
        margin: EdgeInsets.only(left: min(64, context.dp(24))),
        padding: EdgeInsets.only(
          right: min(32, context.dp(24)),
          bottom: min(12, context.dp(8)),
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.disableColor)),
        ),
        child: ListTile(
          dense: !context.isMobile,
          contentPadding: EdgeInsets.zero,
          title: RichText(
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: '(${dataBab.kodeBab}) ~ ',
              style: context.text.labelSmall?.copyWith(color: Colors.black54),
              children: [
                TextSpan(
                  text: dataBab.namaBab,
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
          trailing: RichText(
            textAlign: TextAlign.center,
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: '${dataBab.jumlahSoal}\n',
              style: context.text.titleMedium
                  ?.copyWith(color: Colors.black87.withOpacity(0.7)),
              children: [
                TextSpan(
                  text: 'SOAL',
                  style: context.text.labelSmall
                      ?.copyWith(color: Colors.black87.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
