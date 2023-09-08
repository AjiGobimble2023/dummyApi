// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:kreasi/features/soal/module/timer_soal/entity/tob.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../provider/paket_soal_provider.dart';
import '../../entity/paket_soal.dart';
import '../../../../model/detail_hasil_model.dart';
import '../../../../presentation/provider/solusi_provider.dart';
import '../../../../../leaderboard/model/capaian_detail_score.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../leaderboard/presentation/widget/home/detail_capaian_chart.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [PaketSoalList] merupakan Widget List Bundel Soal.<br><br>
/// Digunakan pada produk-produk berikut:<br>
/// 1. Empati Mandiri (id: 71).<br>
/// 2. Empati Wajib (id: 72).<br>
/// 3. Visual, Auditori, kinestetik (VAK) (id: 65).
class PaketSoalList extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final String diBukaDari;
  final bool isRencanaPicker;

  /// [kodeTOB] dikirim dari rencana belajar notification
  /// untuk keperluan Kuis dan Racing
  final String? kodeTOB;

  /// [kodePaket] dikirim dari rencana belajar notification
  /// untuk keperluan Kuis dan Racing
  final String? kodePaket;

  const PaketSoalList({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.diBukaDari,
    this.isRencanaPicker = false,
    this.kodeTOB,
    this.kodePaket,
  }) : super(key: key);

  @override
  State<PaketSoalList> createState() => _PaketSoalListState();
}

class _PaketSoalListState extends State<PaketSoalList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<PaketSoalProvider, List<PaketSoal>>(
      selector: (_, paket) =>
          paket.getListPaketByJenisProduk(widget.idJenisProduk),
      shouldRebuild: (previous, next) => next.any((paket) {
        bool shouldRebuild = next.length != previous.length;

        if (!shouldRebuild &&
            previous.any((prev) =>
                prev.kodePaket == paket.kodePaket &&
                prev.kodeTOB == paket.kodeTOB)) {
          var prevPaket = previous
              .where((prev) =>
                  prev.kodePaket == paket.kodePaket &&
                  prev.kodeTOB == paket.kodeTOB)
              .first;

          shouldRebuild =
              paket.tanggalKedaluwarsa != prevPaket.tanggalKedaluwarsa ||
                  paket.tanggalBerlaku != prevPaket.tanggalBerlaku ||
                  paket.totalWaktu != prevPaket.totalWaktu ||
                  paket.jumlahSoal != prevPaket.jumlahSoal ||
                  paket.deskripsi != prevPaket.deskripsi ||
                  paket.isTeaser != prevPaket.isTeaser;
        }

        return shouldRebuild;
      }),
      builder: (_, listPaketSoal, child) => FutureBuilder<void>(
          future: _onRefreshPaket(false),
          builder: (context, snapshot) {
            final bool isLoadingPaket =
                snapshot.connectionState == ConnectionState.waiting ||
                    context.select<PaketSoalProvider, bool>(
                        (paket) => paket.isLoadingPaket);

            if (isLoadingPaket) {
              return child!;
            }

            var refreshWidget = MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaleFactor: context.textScale12),
              child: CustomSmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefreshPaket,
                isDark: true,
                child: (listPaketSoal.isEmpty)
                    ? _getIllustrationImage(widget.idJenisProduk)
                    : _buildListPaketSoal(listPaketSoal),
              ),
            );

            return (listPaketSoal.isEmpty)
                ? refreshWidget
                : WatermarkWidget(child: refreshWidget);
          }),
      child: const ShimmerListTiles(isWatermarked: true),
    );
  }

  // On Refresh Function
  Future<void> _onRefreshPaket([bool refresh = true]) async {
    // Function load and refresh data
    await context
        .read<PaketSoalProvider>()
        .getDaftarPaketSoal(
            isRefresh: refresh,
            noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
            idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
                _authOtpProvider.idSekolahKelas.value ??
                '14',
            idJenisProduk: widget.idJenisProduk,
            isProdukDibeli:
                _authOtpProvider.isProdukDibeliSiswa(widget.idJenisProduk),
            roleTeaser: _authOtpProvider.teaserRole)
        .onError((error, stackTrace) => _refreshController.refreshFailed())
        .then((_) => _refreshController.refreshCompleted());

    await gSetServerTimeOffset();
  }

  bool _isSimpan(int idJenisProduk) {
    switch (idJenisProduk) {
      case 71: // Empati Mandiri
        return true;
      case 65: // VAK
      case 72: // Empati Wajib
      default:
        return false;
    }
  }

  bool _isBisaBookmark(int idJenisProduk) {
    switch (idJenisProduk) {
      case 65: // VAK
        return false;
      case 71: // Empati Mandiri
      case 72: // Empati Wajib
      default:
        return true;
    }
  }

  Future<void> _navigateToSoalBasicScreen({
    required String kodeTOB,
    required String kodePaket,
    String? tanggalKedaluwarsa,
  }) async {
    Map<String, dynamic> argument = {
      'idJenisProduk': widget.idJenisProduk,
      'namaJenisProduk': widget.namaJenisProduk,
      'diBukaDariRoute': (widget.diBukaDari == Constant.kRouteTobkScreen)
          ? Constant.kRouteBukuSoalScreen
          : widget.diBukaDari,
      'kodeTOB': kodeTOB,
      'kodePaket': kodePaket,
      // idBundel pada paket terdapat di masing" object soal.
      'idBundel': null,
      // namaKelompokUjian pada paket terdapat di masing" object soal.
      'namaKelompokUjian': null,
      'kodeBab': null,
      'namaBab': null,
      // 'tanggalKedaluwarsa': (widget.idJenisProduk == 72) ? tanggalKedaluwarsa : null,
      'tanggalKedaluwarsa': tanggalKedaluwarsa,
      'isPaket': true,
      'isSimpan': _isSimpan(widget.idJenisProduk),
      'isBisaBookmark': _isBisaBookmark(widget.idJenisProduk)
    };

    if (widget.isRencanaPicker) {
      argument.putIfAbsent(
        'keterangan',
        () =>
            'Mengerjakan ${widget.namaJenisProduk.replaceFirst('e-', '')} dengan Kode Paket $kodePaket.',
      );
      // Kirim data ke Rencana Belajar Editor
      Navigator.pop(context, argument);
    } else {
      bool confirmNavigate = true;
      if (widget.idJenisProduk == 72) {
        confirmNavigate = await _showPrasyaratEmpatiWajib(
          kodePaket: kodePaket,
        );
      }
      if (confirmNavigate) {
        Future.delayed(gDelayedNavigation).then(
          (value) => Navigator.pushNamed(
            context,
            Constant.kRouteSoalBasicScreen,
            arguments: argument,
          ),
        );
      }
    }
  }

  Future<bool> _showPrasyaratEmpatiWajib({
    required String kodePaket,
  }) async {
    List<Tob> listTOBBersyarat = await context
        .read<PaketSoalProvider>()
        .getDaftarTOBBersyarat(kodePaket: kodePaket);

    return await gShowBottomDialogInfo(
      context,
      title: kodePaket,
      message: '',
      dialogType: DialogType.info,
      actions: (controller) => [
        ElevatedButton(
          onPressed: () => controller.dismiss(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.secondaryContainer,
            foregroundColor: context.onSecondaryContainer,
            textStyle: context.text.labelSmall,
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mulai Empati '),
              Icon(Icons.keyboard_double_arrow_right_rounded, size: 14),
            ],
          ),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (listTOBBersyarat.isNotEmpty)
            const Text('merupakan prasyarat dari:'),
          if (listTOBBersyarat.isNotEmpty) const SizedBox(height: 12),
          if (listTOBBersyarat.isNotEmpty)
            ...listTOBBersyarat
                .map<Widget>((tob) => _buildItemTOBBersyarat(context, tob))
                .toList(),
          if (listTOBBersyarat.isNotEmpty) const SizedBox(height: 12),
          Text(
            'Syarat lulus Empati Wajib sebagai prasyarat TOBK:',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.only(
              left: context.dw * 0.08,
            ),
            child: Math.tex(
              r'\frac {\text{Jumlah Benar Kumulatif}}{\text{Jumlah Soal Kumulatif}} \geqslant 50 \%',
              mathStyle: MathStyle.display,
              textStyle: context.text.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTOBBersyarat(BuildContext context, Tob tob) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        child: GestureDetector(
          onTap: () {
            // Untuk menutup bottom sheet.
            if (gPreviousBottomDialog?.isDisposed == false) {
              gPreviousBottomDialog?.dismiss(false);
            }

            Map<String, dynamic> argument = {
              'idJenisProduk': 25,
              'namaJenisProduk': 'e-TOBK',
              'kodeTOB': tob.kodeTOB,
              'namaTOB': tob.namaTOB,
              'diBukaDari': Constant.kRouteBukuSoalScreen,
            };

            logger.log(
                'Paket Soal Dari TOBK >> ${widget.diBukaDari == Constant.kRouteTobkScreen}');
            logger.log('Paket Soal Dibuka Dari >> ${widget.diBukaDari}');

            if (widget.diBukaDari == Constant.kRouteTobkScreen) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Constant.kRouteTobkScreen,
                (route) => route.isFirst,
                arguments: argument,
              );
            } else {
              Navigator.pushNamed(
                context,
                Constant.kRouteTobkScreen,
                arguments: argument,
              );
            }
          },
          child: Container(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.tertiaryColor),
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tob.jenisTOB,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: context.textScale12,
                    style: context.text.labelMedium?.copyWith(
                      color: context.tertiaryColor,
                    ),
                  ),
                  VerticalDivider(
                      color: context.hintColor, width: 18, thickness: 0.4),
                  Text(
                    tob.namaTOB,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: context.textScale12,
                    style: context.text.labelMedium?.copyWith(
                      color: context.onBackground,
                    ),
                  ),
                  VerticalDivider(
                      color: context.hintColor, width: 10, thickness: 0.4),
                  Icon(Icons.keyboard_arrow_right_rounded,
                      color: context.onBackground, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Get Illustration Image Function
  Widget _getIllustrationImage(int idJenisProduk) {
    bool isProdukDibeli = _authOtpProvider.isProdukDibeliSiswa(idJenisProduk,
        ortuBolehAkses: true);
    // 76: Latex, 77: Paket Intensif, 78: Soal Koding, 79: Pend Materi, 82: SoRef
    String imageUrl = 'ilustrasi_soal_emwa.png'.illustration;
    String title = 'Buku Soal';

    switch (idJenisProduk) {
      case 65:
        imageUrl = 'ilustrasi_profiling.png'.illustration;
        title = 'VAK';
        break;
      case 71:
        imageUrl = 'ilustrasi_soal_emma.png'.illustration;
        title = 'Empati Mandiri';
        break;
      case 72:
        title = 'Empati Wajib';
        break;
      default:
        break;
    }

    Widget basicEmpty = BasicEmpty(
      shrink: (context.dh < 600) ? !context.isMobile : false,
      imageUrl: imageUrl,
      title: title,
      subTitle: gEmptyProductSubtitle(
          namaProduk: title,
          isProdukDibeli: isProdukDibeli,
          isOrtu: _authOtpProvider.isOrtu,
          isNotSiswa: !_authOtpProvider.isSiswa),
      emptyMessage: gEmptyProductText(
          namaProduk: title,
          isProdukDibeli: isProdukDibeli,
          isOrtu: _authOtpProvider.isOrtu),
    );

    return (context.isMobile || context.dh > 600)
        ? basicEmpty
        : SingleChildScrollView(
            child: basicEmpty,
          );
  }

  Widget _buildLeadingItem({
    required PaketSoal paketSoal,
    required bool isTeaser,
    required bool isKedaluwarsa,
  }) {
    Color containerColor = (isKedaluwarsa)
        ? context.disableColor
        : (isTeaser)
            ? context.tertiaryColor
            : context.background;
    Color textColor = (isKedaluwarsa)
        ? context.disableColor
        : (isTeaser)
            ? context.onTertiary
            : context.tertiaryColor;

    var leadingWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: min(12, context.dp(8)),
        vertical: min(14, context.dp(8)),
      ),
      constraints: BoxConstraints(minWidth: min(118, context.dp(72))),
      decoration: BoxDecoration(
        color: containerColor,
        border: (isTeaser || isKedaluwarsa)
            ? null
            : Border.all(color: context.tertiaryColor),
        borderRadius: BorderRadius.circular(min(18, context.dp(14))),
      ),
      child: Text(
        (context.isMobile)
            ? paketSoal.kodePaket.replaceAll('-', '\n')
            : paketSoal.kodePaket,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.fade,
        style: context.text.labelMedium?.copyWith(
          fontSize: (context.isMobile) ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );

    return !isTeaser
        ? leadingWidget
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'TEASER',
                  style: context.text.labelSmall?.copyWith(
                    color: isKedaluwarsa
                        ? context.disableColor
                        : context.tertiaryColor,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              leadingWidget,
            ],
          );
  }

  // List Paket Soal Widgets
  Widget _buildListPaketSoal(List<PaketSoal> listPaket) {
    return ListView.builder(
      itemCount: listPaket.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: context.dp(12), bottom: context.dp(30)),
      itemBuilder: (_, index) {
        final PaketSoal paketSoal = listPaket[index];
        final bool isKedaluwarsa = paketSoal.isKedaluwarsa;

        return _buildItemPaket(paketSoal, isKedaluwarsa);
      },
    );
  }
  //
  // // List Paket Soal Widgets
  // Widget _buildListPaketSoal(List<PaketSoal> listPaket) => ListView.builder(
  //       physics: const NeverScrollableScrollPhysics(),
  //       padding: EdgeInsets.only(top: context.dp(12), bottom: context.dp(30)),
  //       itemBuilder: (_, index) {
  //         final PaketSoal paketSoal = listPaket[index];
  //         final bool isKedaluwarsa = paketSoal.isKedaluwarsa;
  //
  //         return _buildItemPaket(paketSoal, isKedaluwarsa);
  //       },
  //       itemCount: listPaket.length,
  //     );

  Widget _buildItemPaket(PaketSoal paketSoal, bool isKedaluwarsa) {
    return InkWell(
      onLongPress: () => _showDetailHasil(context, paketSoal),
      onTap: () => _navigateToSoalBasicScreen(
        kodeTOB: paketSoal.kodeTOB,
        kodePaket: paketSoal.kodePaket,
        tanggalKedaluwarsa: paketSoal.tanggalKedaluwarsa,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (paketSoal.kodePaket == widget.kodePaket)
              ? context.secondaryContainer
              : (isKedaluwarsa)
                  ? context.disableColor
                  : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(width: 0.5, color: context.hintColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeadingItem(
                    paketSoal: paketSoal,
                    isTeaser: paketSoal.isTeaser,
                    isKedaluwarsa: isKedaluwarsa),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (paketSoal.deskripsi.isNotEmpty ||
                                paketSoal.deskripsi != '-')
                            ? paketSoal.deskripsi.trim()
                            : paketSoal.kodePaket,
                        style: context.text.labelMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        semanticsLabel: 'Paket ${paketSoal.deskripsi}',
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.rocket_launch_outlined,
                              color: (isKedaluwarsa)
                                  ? context.hintColor
                                  : context.tertiaryColor,
                              size: 18),
                          Text(
                            ' ${(widget.idJenisProduk == 65) ? 'Level ${paketSoal.tingkat}' : paketSoal.sekolahKelas}'
                            ' | ${paketSoal.jumlahSoal} soal',
                            semanticsLabel: 'Level ${paketSoal.sekolahKelas}, '
                                '${paketSoal.jumlahSoal} soal',
                            style: context.text.bodySmall?.copyWith(
                              color: (isKedaluwarsa)
                                  ? context.hintColor
                                  : context.tertiaryColor,
                              fontSize: 11,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 0.15, indent: 12, endIndent: 12),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      (isKedaluwarsa)
                          ? 'Berakhir pada: ${paketSoal.displayTanggalKedaluwarsa}'
                          : 'Dimulai: ${paketSoal.displayTanggalBerlaku}\n'
                              'Berakhir: ${paketSoal.displayTanggalKedaluwarsa}',
                      semanticsLabel: 'Waktu tayag paket soal',
                      style: context.text.bodySmall?.copyWith(
                        color: context.onBackground.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const VerticalDivider(),
                  InkWell(
                    onTap: () async => _showDetailHasil(context, paketSoal),
                    child: Chip(
                      label: const Text('Lihat hasil'),
                      labelStyle: context.text.bodySmall?.copyWith(
                        color: (isKedaluwarsa)
                            ? context.onPrimaryContainer
                            : context.tertiaryColor,
                        fontSize: 10,
                      ),
                      labelPadding: EdgeInsets.zero,
                      padding: (context.isMobile)
                          ? const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12)
                          : const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                      backgroundColor:
                          (isKedaluwarsa) ? context.primaryContainer : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.dp(32)),
                          side: BorderSide(color: context.tertiaryColor)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showDetailHasil(BuildContext context, PaketSoal paketSoal) async {
    final getDetailHasil = context.read<SolusiProvider>().getDetailHasil(
          noRegistrasi: gNoRegistrasi,
          idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
              _authOtpProvider.idSekolahKelas.value!,
          kodePaket: paketSoal.kodePaket,
          jumlahSoal: paketSoal.jumlahSoal,
          jenisHasil: 'paket',
        );

    Widget? childWidget;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: context.dh * 0.9),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        childWidget ??= Selector<SolusiProvider, List<DetailHasilModel>>(
            selector: (_, solusi) => solusi.listDetailHasil,
            builder: (context, listDetailHasil, _) {
              return FutureBuilder(
                future: getDetailHasil,
                builder: (context, snapshot) {
                  bool isLoading =
                      snapshot.connectionState == ConnectionState.waiting ||
                          context.select<SolusiProvider, bool>(
                              (solusi) => solusi.isloading);

                  if (isLoading) {
                    return const ShimmerListTiles(
                        shrinkWrap: true, jumlahItem: 2);
                  }

                  if (listDetailHasil.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: context.dp(18),
                        left: context.dp(18),
                        top: context.dp(24),
                        bottom: context.dp(24),
                      ),
                      child: Text(
                        "Belum ada soal ${paketSoal.kodePaket} yang telah Sobat kerjakan, "
                        "yuk kerjain soal dulu Sobat.",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: context.dp(18), horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: listDetailHasil.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (index == 0)
                              Column(
                                children: [
                                  Center(
                                    child: Text(paketSoal.kodePaket,
                                        style: context.text.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  constraints:
                                      BoxConstraints(maxWidth: context.dw - 32),
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Text(
                                    listDetailHasil[index]
                                        .namaKelompokUjian
                                        .toString(),
                                    style: context.text.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            DetailCapaianChart(
                              capaianDetail: CapaianDetailScore(
                                label: listDetailHasil[index]
                                    .namaKelompokUjian
                                    .toString(),
                                benar: listDetailHasil[index].benar,
                                salah: listDetailHasil[index].salah,
                                kosong: listDetailHasil[index].kosong,
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            });

        return childWidget!;
      },
    );
  }
}
