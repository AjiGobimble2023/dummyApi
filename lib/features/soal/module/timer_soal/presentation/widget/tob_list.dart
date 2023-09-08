// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flash/flash_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'popup_tobk_bersyarat.dart';
import '../provider/tob_provider.dart';
import '../../entity/tob.dart';
import '../../entity/syarat_tobk.dart';
import '../../../../../profile/entity/kelompok_ujian.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../profile/presentation/widget/pilih_kelompok_ujian.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/helper/hive_helper.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [TOBList] merupakan Widget List TOB.<br><br>
/// Digunakan pada produk-produk berikut:<br>
/// 1. TOBK (id: 25).<br>
class TOBList extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final bool isRencanaPicker;

  /// [selectedKodeTOB] merupakan kodeTOB yang didapat dari rencana belajar
  /// atau onClick Notification
  final String? selectedKodeTOB;

  /// [selectedKodeTOB] merupakan namaTOB yang didapat dari rencana belajar
  /// atau onClick Notification
  final String? selectedNamaTOB;

  /// Untuk keperluan handle push and pop
  final String? diBukaDari;

  const TOBList({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    this.isRencanaPicker = false,
    this.selectedKodeTOB,
    this.selectedNamaTOB,
    this.diBukaDari,
  }) : super(key: key);

  @override
  State<TOBList> createState() => _TOBListState();
}

class _TOBListState extends State<TOBList> {
  late final NavigatorState _navigator = Navigator.of(context);
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();

  @override
  void dispose() {
    _refreshController.dispose();
    if (HiveHelper.isBoxOpen<KelompokUjian>(
        boxName: HiveHelper.kKelompokUjianPilihanBox)) {
      HiveHelper.closeBox<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox);
    }
    if (HiveHelper.isBoxOpen<List<KelompokUjian>>(
        boxName: HiveHelper.kKonfirmasiTOMerdekaBox)) {
      HiveHelper.closeBox<List<KelompokUjian>>(
          boxName: HiveHelper.kKonfirmasiTOMerdekaBox);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaleFactor: context.textScale12),
      child: Selector<TOBProvider, List<Tob>>(
        selector: (_, tob) => tob.getListTOBByJenisProduk(widget.idJenisProduk),
        shouldRebuild: (previous, next) => next.any((tob) {
          bool shouldRebuild = next.length != previous.length;

          if (!shouldRebuild &&
              previous.any((prev) => prev.kodeTOB == tob.kodeTOB)) {
            var prevTOB =
                previous.where((prev) => prev.kodeTOB == tob.kodeTOB).first;

            shouldRebuild = tob.tanggalMulai != prevTOB.tanggalMulai ||
                tob.tanggalBerakhir != prevTOB.tanggalBerakhir ||
                tob.namaTOB != prevTOB.namaTOB ||
                tob.jarakAntarPaket != prevTOB.jarakAntarPaket ||
                tob.isBersyarat != prevTOB.isBersyarat ||
                tob.isTeaser != prevTOB.isTeaser;
          }

          return shouldRebuild;
        }),
        builder: (_, listTOB, child) => FutureBuilder<void>(
            future: _onRefreshTOB(false),
            builder: (context, snapshot) {
              final bool isLoadingTOB = snapshot.connectionState ==
                      ConnectionState.waiting ||
                  context.select<TOBProvider, bool>((tob) => tob.isLoadingTOB);

              if (isLoadingTOB) {
                return child!;
              }

              var refreshWidget = CustomSmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefreshTOB,
                isDark: true,
                child: (listTOB.isEmpty)
                    ? _getIllustrationImage(widget.idJenisProduk)
                    : _buildListTOB(listTOB),
              );

              return (listTOB.isEmpty)
                  ? refreshWidget
                  : WatermarkWidget(child: refreshWidget);
            }),
        child: const ShimmerListTiles(isWatermarked: true),
      ),
    );
  }

  // On Refresh Function
  Future<void> _onRefreshTOB([bool refresh = true]) async {
    // Function load and refresh data
    await context
        .read<TOBProvider>()
        .getDaftarTOB(
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

    // Open KelompokUjianPilihanBox untuk mengecek
    // pilihan mata uji untuk TOBK merdeka.
    if (!HiveHelper.isBoxOpen<KelompokUjian>(
        boxName: HiveHelper.kKelompokUjianPilihanBox)) {
      await HiveHelper.openBox<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox);
    }
    if (!HiveHelper.isBoxOpen<List<KelompokUjian>>(
        boxName: HiveHelper.kKonfirmasiTOMerdekaBox)) {
      await HiveHelper.openBox<List<KelompokUjian>>(
          boxName: HiveHelper.kKonfirmasiTOMerdekaBox);
    }
  }

  Future<bool> _pilihKelompokUjian({required Tob tob}) async {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    bool? sudahTerkonfirmasi = await showModalBottomSheet(
      context: context,
      elevation: 4,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: context.background,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        childWidget ??= const PilihKelompokUjian(isFromTOBK: true);
        return childWidget!;
      },
    );

    if (sudahTerkonfirmasi ?? false) {
      await HiveHelper.saveKonfirmasiTOMerdeka(kodeTOB: tob.kodeTOB);
    }

    if (!(sudahTerkonfirmasi ?? false) && mounted) {
      gShowBottomDialogInfo(context,
          title: 'Belum Mengkonfirmasi Mata Uji Pilihan',
          message:
              'TryOut ${tob.namaTOB} merupakan TryOut dengan format kurikulum merdeka. '
              'TryOut kurikulum merdeka membutuhkan konfirmasi mata uji pilihan');
    }

    return sudahTerkonfirmasi ?? false;
  }

  Future<bool> _popUpTOBKBersyarat({
    SyaratTOBK? syaratTOBK,
    required Tob tob,
    required TOBProvider tobProvider,
  }) async {
    SyaratTOBK? syarat = (syaratTOBK == null)
        ? await tobProvider.cekBolehTO(
            noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
            kodeTOB: tob.kodeTOB,
            namaTOB: tob.namaTOB)
        : syaratTOBK;

    final popUpWidget = PopUpTOBKBersyarat(
      syaratTOBK: syarat,
      namaTOB: tob.namaTOB,
      diBukaDari: widget.diBukaDari,
    );

    bool? confirmMulai = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(
        maxWidth: min(650, context.dw),
        maxHeight: context.dh * 0.89,
      ),
      builder: (context) => popUpWidget,
    );

    return confirmMulai ?? false;
  }

  // ON-CLICK TOB
  Future<void> _onClickTOB({
    required Tob tob,
    required TOBProvider tobProvider,
    required Map<String, dynamic> paramsLaporan,
  }) async {
    if (widget.isRencanaPicker) {
      final dateNowServer = DateTime.now().serverTimeFromOffset;
      var isBerakhir = tob.isTOBBerakhir(dateNowServer);

      if (!isBerakhir) {
        // Kembali ke Rencana Belajar Editor
        Navigator.pop(context, {
          'idJenisProduk': 25,
          'namaJenisProduk': 'e-TOBK',
          'kodeTOB': tob.kodeTOB,
          'namaTOB': tob.namaTOB,
          'keterangan':
              'Mengerjakan TryOut ${tob.namaTOB} dimulai pada ${tob.displayTanggalMulai} '
                  'sampai dengan ${tob.displayTanggalBerakhir}',
        });
      } else {
        gShowBottomDialogInfo(context,
            title: 'TryOut ${tob.namaTOB} Telah Berakhir',
            message: 'Kamu tidak dapat memilih TryOut ${tob.namaTOB} '
                'untuk rencana belajar karena TryOut ini telah berakhir!');
      }
    } else {
      List<KelompokUjian> daftarMataUjiPilihan = [];
      // List<KampusImpian> daftarJurusanPilihan = [];
      SyaratTOBK? syaratTOBK = tob.isBersyarat
          ? await tobProvider.cekBolehTO(
              noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
              kodeTOB: tob.kodeTOB,
              namaTOB: tob.namaTOB)
          : null;
      bool isBolehTO = tob.isBersyarat ? syaratTOBK?.isLulus ?? false : true;

      if (tob.isBersyarat) {
        isBolehTO = await _popUpTOBKBersyarat(
          syaratTOBK: syaratTOBK,
          tob: tob,
          tobProvider: tobProvider,
        );
      }

      if (isBolehTO && tob.isFormatTOMerdeka) {
        daftarMataUjiPilihan =
            await HiveHelper.getKonfirmasiTOMerdeka(kodeTOB: tob.kodeTOB);

        if (daftarMataUjiPilihan.isEmpty) {
          isBolehTO = await _pilihKelompokUjian(tob: tob);
          daftarMataUjiPilihan =
              await HiveHelper.getKonfirmasiTOMerdeka(kodeTOB: tob.kodeTOB);
        }
      }

      if (isBolehTO) {
        var completer = Completer();
        context.showBlockDialog(dismissCompleter: completer);

        DateTime serverTime = await gGetServerTime();
        tobProvider.serverTime = serverTime;

        String deviceId = await gGetIdDevice() ?? 'FAILED_TO_GET_DEVICE_ID';

        // bool isBolehMengerjakan = (tob.isBersyarat)
        //     ? tob.isTOBRunning(serverTime) && (syaratTOBK?.isLulus ?? false)
        //     : tob.isTOBRunning(serverTime);
        completer.complete();
        _navigator.pushNamed(Constant.kRoutePaketTOScreen, arguments: {
          'idJenisProduk': widget.idJenisProduk,
          'namaJenisProduk': widget.namaJenisProduk,
          'paramsLaporan': paramsLaporan,
          'kodeTOB': tob.kodeTOB,
          'noRegistrasi': _authOtpProvider.userData?.noRegistrasi ?? deviceId,
          'namaTOB': tob.namaTOB,
          'interval': tob.jarakAntarPaket,
          'tanggalMulai': tob.tanggalMulaiDateTime,
          'tanggalBerakhir': tob.tanggalBerakhirDateTime,
          'isFormatTOMerdeka': tob.isFormatTOMerdeka,
          'daftarMataUjiPilihan': daftarMataUjiPilihan,
          'isBolehLihatKisiKisi': tob.isBolehLihatKisiKisi(serverTime),
          'isTOBRunning': tob.isTOBRunning(serverTime),
          'isMemenuhiSyarat':
              (tob.isBersyarat) ? (syaratTOBK?.isLulus ?? false) : true,
        });
      }
    }
  }

  // Get Illustration Image Function
  BasicEmpty _getIllustrationImage(int idJenisProduk) {
    bool isProdukDibeli = _authOtpProvider.isProdukDibeliSiswa(idJenisProduk,
        ortuBolehAkses: true);
    String imageUrl = 'ilustrasi_tobk.png'.illustration;
    String title = 'TryOut Berbasis Komputer';

    return BasicEmpty(
      isLandscape: !context.isMobile,
      imageUrl: imageUrl,
      title: title,
      subTitle: gEmptyProductSubtitle(
          namaProduk: title,
          isProdukDibeli: isProdukDibeli,
          isOrtu: _authOtpProvider.isOrtu,
          isNotSiswa: !_authOtpProvider.isSiswa),
      emptyMessage: gEmptyProductText(
        namaProduk: title,
        isOrtu: _authOtpProvider.isOrtu,
        isProdukDibeli: isProdukDibeli,
      ),
    );
  }

  Widget _buildLeadingItem({
    required Tob tob,
    required bool isTeaser,
    required bool isKedaluwarsa,
  }) {
    Widget leadingWidget = Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: min(12, context.dp(8)),
        vertical: min(14, context.dp(6)),
      ),
      constraints: BoxConstraints(
        minWidth: min(76, context.dp(72)),
        maxWidth: min(80, context.dp(76)),
        minHeight: min(36, context.dp(32)),
        maxHeight: min(46, context.dp(42)),
      ),
      decoration: BoxDecoration(
        color: isKedaluwarsa
            ? context.disableColor
            : isTeaser
                ? context.tertiaryColor
                : context.background,
        border: (isTeaser || isKedaluwarsa)
            ? null
            : Border.all(color: context.tertiaryColor),
        borderRadius: BorderRadius.circular(min(16, context.dp(14))),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          // 'Ujian\nSekolah',
          (context.isMobile)
              ? tob.jenisTOB.replaceAll(' ', '\n')
              : tob.jenisTOB,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: context.text.labelMedium?.copyWith(
            fontSize: (context.isMobile) ? 12 : 10,
            fontWeight: FontWeight.bold,
            color: isKedaluwarsa
                ? context.disableColor
                : isTeaser
                    ? context.onTertiary
                    : context.tertiaryColor,
          ),
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

  // List Bundel Widgets
  Widget _buildListTOB(List<Tob> listTOB) {
    // initial kodeTOB di perlukan untuk keperluan Rencana Belajar.
    int initialTOBIndex = (widget.selectedKodeTOB == null)
        ? 0
        : listTOB.indexWhere((tob) => tob.kodeTOB == widget.selectedKodeTOB);

    if (kDebugMode) {
      logger.log('TOB_LIST-ListTOB: initial index >> $initialTOBIndex');
      logger.log('TOB_LIST-ListTOB: selected KodeTOB '
          '>> ${widget.selectedKodeTOB}, ${widget.selectedNamaTOB}');
    }

    if (initialTOBIndex < 0) {
      initialTOBIndex = 0;

      gShowBottomDialogInfo(context,
          message: 'Tryout ${widget.selectedNamaTOB} tidak ditemukan');
    }

    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 8, bottom: context.dp(30)),
        itemCount: (context.isMobile)
            ? listTOB.length
            : (listTOB.length.isEven)
                ? (listTOB.length / 2).floor()
                : (listTOB.length / 2).floor() + 1,
        itemBuilder: (context, index) {
          return (context.isMobile)
              ? _buildItemTOB(
                  context,
                  index: index,
                  listTOB: listTOB,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildItemTOB(
                        context,
                        index: index * 2,
                        listTOB: listTOB,
                      ),
                    ),
                    (((index * 2) + 1) < listTOB.length)
                        ? Expanded(
                            child: _buildItemTOB(
                              context,
                              index: (index * 2) + 1,
                              listTOB: listTOB,
                            ),
                          )
                        : const Spacer(),
                  ],
                );
        });
  }

  Widget _buildItemTOB(
    BuildContext context, {
    required int index,
    required List<Tob> listTOB,
  }) {
    return Builder(builder: (context) {
      TOBProvider tobProvider = context.read<TOBProvider>();
      Tob tob = listTOB[index];
      bool isTOBBerakhir = listTOB[index].isTOBBerakhir(tobProvider.serverTime);
      Map<String, dynamic> paramsLaporan = {
        "penilaian": (tob.jenisTOB == "UTBK") ? "IRT" : "B Saja",
        "kodeTOB": tob.kodeTOB,
        'namaTOB': tob.namaTOB,
        'jenisTO': tob.jenisTOB,
        'showEPB': false,
        'isExists': false,
        'link': "",
      };

      return InkWell(
        onTap: () async => await _onClickTOB(
          tob: tob,
          tobProvider: tobProvider,
          paramsLaporan: paramsLaporan,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (widget.selectedNamaTOB == tob.namaTOB)
                ? context.secondaryContainer
                : (isTOBBerakhir)
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
                    tob: tob,
                    isTeaser: tob.isTeaser,
                    isKedaluwarsa: isTOBBerakhir,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tob.namaTOB,
                          style: context.text.labelMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          semanticsLabel: tob.namaTOB,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (tob.isBersyarat)
                              Icon(Icons.gpp_maybe_outlined,
                                  color: (isTOBBerakhir)
                                      ? context.hintColor
                                      : context.primaryColor,
                                  size: 18),
                            if (tob.isBersyarat)
                              Text(
                                ' Bersyarat |  ',
                                semanticsLabel:
                                    'bersyarat ${tob.isBersyarat}',
                                style: context.text.bodySmall?.copyWith(
                                    color: (isTOBBerakhir)
                                        ? context.hintColor
                                        : context.tertiaryColor,
                                    fontSize: 11),
                              ),
                            Icon(Icons.settings_ethernet_rounded,
                                color: (isTOBBerakhir)
                                    ? context.hintColor
                                    : context.tertiaryColor,
                                size: 18),
                            Expanded(
                              child: Text(
                                '  ${tob.jarakAntarPaket} menit interval',
                                semanticsLabel:
                                    '${tob.jarakAntarPaket} menit interval',
                                style: context.text.bodySmall?.copyWith(
                                  color: (isTOBBerakhir)
                                      ? context.hintColor
                                      : context.tertiaryColor,
                                  fontSize: 11,
                                ),
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
                        (isTOBBerakhir)
                            ? 'Berakhir pada: ${tob.displayTanggalBerakhir}'
                            : 'Dimulai: ${tob.displayTanggalMulai}\n'
                                'Berakhir: ${tob.displayTanggalBerakhir}',
                        semanticsLabel: 'Waktu tayag paket soal',
                        style: context.text.bodySmall?.copyWith(
                          color: context.onBackground.withOpacity(0.8),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_authOtpProvider.isLogin) {
                          if (isTOBBerakhir) {
                            Navigator.of(context).pushNamed(
                                Constant.kRouteLaporanTryOutNilai,
                                arguments: paramsLaporan);
                          } else {
                            gShowBottomDialogInfo(context,
                                message: '${tob.namaTOB} belum berakhir, '
                                    'sehingga kamu belum bisa melihat hasil TryOut.');
                          }
                        } else {
                          gShowBottomDialogInfo(context,
                              message: 'Laporan Try Out hanya tersedia '
                                  'untuk siswa Ganesha Operation');
                        }
                      },
                      child: Chip(
                        label: Text(
                            (context.isMobile) ? 'Laporan' : 'Lihat Laporan'),
                        labelStyle: context.text.bodySmall?.copyWith(
                          color: (isTOBBerakhir)
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
                            (isTOBBerakhir) ? context.primaryContainer : null,
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
    });
  }
}
