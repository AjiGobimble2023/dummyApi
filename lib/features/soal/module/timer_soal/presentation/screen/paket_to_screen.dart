// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../provider/tob_provider.dart';
import '../../entity/paket_to.dart';
import '../../../../presentation/widget/kisi_kisi_widget.dart';
import '../../../../../profile/entity/kelompok_ujian.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/util/data_formatter.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [PaketToScreen] halaman yang digunakan untuk menampilkan daftar
/// Paket Soal khusus dari TOBK (id: 25).
class PaketToScreen extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final String kodeTOB;
  final String namaTOB;
  final String noRegistrasi;
  final int jarakAntarPaket;
  final DateTime tanggalMulaiTO;
  final DateTime tanggalBerakhirTO;
  final List<KelompokUjian> daftarMataUjiPilihan;
  final bool isFormatTOMerdeka;
  final bool isBolehLihatKisiKisi;
  final bool isTOBRunning;
  final bool isMemenuhiSyarat;
  final Map<String, dynamic> paramsLaporan;

  const PaketToScreen({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.kodeTOB,
    required this.noRegistrasi,
    required this.jarakAntarPaket,
    required this.tanggalMulaiTO,
    required this.tanggalBerakhirTO,
    required this.namaTOB,
    required this.isFormatTOMerdeka,
    required this.isBolehLihatKisiKisi,
    required this.isTOBRunning,
    required this.isMemenuhiSyarat,
    required this.daftarMataUjiPilihan,
    required this.paramsLaporan,
  }) : super(key: key);

  @override
  State<PaketToScreen> createState() => _PaketToScreenState();
}

class _PaketToScreenState extends State<PaketToScreen> {
  // late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();
  late final NavigatorState _navigator = Navigator.of(context);
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  DateTime _serverTime = DateTime.now().serverTimeFromOffset;
  late final String _displayTOBBerakhir = DataFormatter.formatDate(
    DataFormatter.dateTimeToString(widget.tanggalBerakhirTO),
    '[HH:mm] dd MMM y',
  );
  late final String _displayTOBMulai = DataFormatter.formatDate(
    DataFormatter.dateTimeToString(widget.tanggalMulaiTO),
    '[HH:mm] dd MMM y',
  );

  @override
  void dispose() async {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _serverTime =
        context.select<TOBProvider, DateTime>((tob) => tob.serverTime);

    return BasicScreen(
      title: widget.namaTOB,
      subTitle: (_serverTime.isAfter(widget.tanggalBerakhirTO))
          ? 'Berakhir Pada: $_displayTOBBerakhir'
          : (!widget.isTOBRunning)
              ? 'Dimulai Pada: $_displayTOBMulai'
              : (widget.jarakAntarPaket > 0)
                  ? 'Interval: ${widget.jarakAntarPaket} menit'
                  : 'Dimulai Pada: $_displayTOBMulai',
      jumlahBarisTitle: (widget.jarakAntarPaket > 0) ? 2 : 1,
      body: (_serverTime.isAfter(widget.tanggalBerakhirTO)) ||
              (!widget.isTOBRunning) ||
              (!widget.isMemenuhiSyarat)
          ? Column(
              children: [
                _buildPesanTryoutSelesai(),
                Expanded(child: _buildPaketTOContent(_serverTime)),
              ],
            )
          : _buildPaketTOContent(_serverTime),
      floatingActionButton: (_serverTime.isAfter(widget.tanggalBerakhirTO))
          ? ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                    Constant.kRouteLaporanTryOutNilai,
                    arguments: widget.paramsLaporan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.secondaryContainer,
                foregroundColor: context.onSecondaryContainer,
                padding: EdgeInsets.only(
                  right: (context.isMobile) ? context.dp(18) : 24,
                  left: (context.isMobile) ? context.dp(14) : 18,
                  top: (context.isMobile) ? context.dp(12) : 16,
                  bottom: (context.isMobile) ? context.dp(12) : 16,
                ),
              ),
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Lihat Laporan'),
            )
          : null,
    );
  }

  Future<void> _onRefreshPaketTO([bool refresh = true]) async {
    final authProvider = context.read<AuthOtpProvider>();
    final userData = authProvider.userData;
    // Function load and refresh data
    await context
        .read<TOBProvider>()
        .getDaftarPaketTO(
          kodeTOB: widget.kodeTOB,
          noRegistrasi: widget.noRegistrasi,
          idSekolahKelas: userData?.idSekolahKelas,
          idJenisProduk: 25,
          tahunAjaran: authProvider.tahunAjaran,
          teaserRole: userData?.siapa,
          isRefresh: refresh,
        )
        .onError((error, stackTrace) => _refreshController.refreshFailed())
        .then((_) => _refreshController.refreshCompleted());

    await gSetServerTimeOffset();

    _serverTime = DateTime.now().serverTimeFromOffset;
  }

  Future<void> _kumpulkanPaket({
    required FlashController controller,
    required PaketTO paketTO,
  }) async {
    final authProvider = context.read<AuthOtpProvider>();
    final tobProvider = context.read<TOBProvider>();
    final completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);

    if (widget.idJenisProduk == 12 || widget.idJenisProduk == 80) {
      await tobProvider.kumpulkanJawabanGOA(
        tahunAjaran: authProvider.tahunAjaran,
        noRegistrasi: authProvider.userData?.noRegistrasi,
        tipeUser: authProvider.userData?.siapa ?? authProvider.userType,
        tingkatKelas:
            authProvider.userData?.tingkatKelas ?? authProvider.tingkatKelas,
        idSekolahKelas: authProvider.userData?.idSekolahKelas ??
            authProvider.idSekolahKelas.value ??
            '14',
        idKota: authProvider.userData?.idKota ?? '',
        idGedung: authProvider.userData?.idGedung ?? '',
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: paketTO.kodeTOB,
        kodePaket: paketTO.kodePaket,
      );
    } else {
      await tobProvider.updatePesertaTO(
        tahunAjaran: authProvider.tahunAjaran,
        noRegistrasi: authProvider.userData?.noRegistrasi,
        tipeUser: authProvider.userData?.siapa ?? authProvider.userType,
        tingkatKelas:
            authProvider.userData?.tingkatKelas ?? authProvider.tingkatKelas,
        idSekolahKelas: authProvider.userData?.idSekolahKelas ??
            authProvider.idSekolahKelas.value ??
            '14',
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: paketTO.kodeTOB,
        kodePaket: paketTO.kodePaket,
      );
    }

    completer.complete();
    controller.dismiss(true);
  }

  /// [hanyaBolehKumpulkan] jika masa TOB sudah berakhir dan maksimal
  /// 1 jam setelah masa TO berakhir.
  Future<void> _onClickPaketTO({
    required PaketTO paketTO,
    PaketTO? paketSelanjutnya,
    required bool isTOBerakhir,
    required bool hanyaBolehKumpulkan,
  }) async {
    if (hanyaBolehKumpulkan) {
      String message = 'Kamu belum mengumpulkan ${paketTO.kodePaket} Sobat. '
          'Kamu tidak bisa lanjut mengerjakan karena batas pengerjaan '
          'paket ${paketTO.kodePaket} hanya sampai ${paketTO.displayDeadlinePengerjaan}. '
          'Kumpulkan ${paketTO.kodePaket} sebelum ${widget.tanggalBerakhirTO.hoursMinutesDDMMMYYYY} ';

      message += (paketSelanjutnya == null)
          ? 'yaa!'
          : 'agar bisa lanjut ke paket ${paketSelanjutnya.kodePaket} ya Sobat!';

      await gShowBottomDialog(
        context,
        title: 'Kumpulkan ${paketTO.kodePaket}',
        message: message,
        actions: (controller) => [
          TextButton(
              onPressed: () async => await _kumpulkanPaket(
                    controller: controller,
                    paketTO: paketTO,
                  ),
              child: const Text('Kumpulkan Sekarang'))
        ],
      );
    } else {
      if ((paketTO.isSelesai ||
              paketTO.tanggalSiswaSubmit != null ||
              paketTO.isWaktuHabis) &&
          !isTOBerakhir) {
        gShowBottomDialogInfo(context,
            dialogType: DialogType.info,
            title: 'Belum Boleh Melihat Solusi',
            message: 'Masa TryOut belum berakhir, kamu baru bisa melihat '
                'solusi setelah ${widget.tanggalBerakhirTO.hoursMinutesDDMMMYYYY}');
        return;
      } else {
        final TOBProvider tobProvider = context.read<TOBProvider>();
        var completer = Completer();
        context.showBlockDialog(dismissCompleter: completer);

        DateTime serverTime = await gGetServerTime();
        tobProvider.serverTime = serverTime;

        completer.complete();
        _navigator.pushNamed(Constant.kRouteSoalTimerScreen, arguments: {
          'kodeTOB': paketTO.kodeTOB,
          'kodePaket': paketTO.kodePaket,
          'idJenisProduk': widget.idJenisProduk,
          'namaJenisProduk': widget.namaJenisProduk,
          'waktu': paketTO.totalWaktu,
          'tanggalSelesai': paketTO.deadlinePengerjaan,
          'tanggalSiswaSubmit': paketTO.tanggalSiswaSubmit,
          'tanggalKedaluwarsaTOB': widget.tanggalBerakhirTO,
          'isBlockingTime': paketTO.isBlockingTime,
          'isPernahMengerjakan': paketTO.isPernahMengerjakan,
          'isRandom': paketTO.isRandom,
          'isBolehLihatSolusi': serverTime.isAfter(widget.tanggalBerakhirTO),
        });
      }
    }
  }

  Future<void> _onClickPaketListTile({
    required PaketTO paketTO,
    PaketTO? paketSebelumnya,
    PaketTO? paketSelanjutnya,
    required bool isPernahMengerjakan,
    required bool isSudahDikumpulkan,
    required bool isWaktuHabis,
  }) async {
    BuildContext ctx = context;
    DateTime serverTime = DateTime.now().serverTimeFromOffset;

    if (kDebugMode) {
      logger.log(
          'PAKET_TO_SCREEN-OnClickPaketListTile: $paketSebelumnya | ${paketSebelumnya?.isSelesai} | ${widget.isBolehLihatKisiKisi}');
    }

    if (serverTime.isBefore(widget.tanggalMulaiTO) ||
        (!widget.isMemenuhiSyarat &&
            !serverTime.isAfter(widget.tanggalBerakhirTO))) {
      gShowBottomDialogInfo(context,
          message: (serverTime.isBefore(widget.tanggalMulaiTO))
              ? 'Hai Sobat! Tryout ini baru akan dimulai pada $_displayTOBMulai. '
                  'Saat ini sobat hanya bisa melihat kisi-kisi saja. '
                  'Yuk persiapkan diri kamu untuk raih hasil yang maksimal!'
              : 'Hai Sobat! Kamu tidak bisa mengerjakan TryOut ini, karena tidak '
                  'memenuhi prasyarat Empati Wajib dari ${widget.namaTOB}. '
                  'Namun, kamu masih bisa melihat kunci dan solusi dari '
                  'TOBK ini setelah periode TOBK berakhir.');
      return;
    }

    if (paketSebelumnya != null &&
        !paketSebelumnya.isSelesai &&
        !serverTime.isAfter(widget.tanggalBerakhirTO)) {
      if (!paketSebelumnya.isPernahMengerjakan) {
        gShowBottomDialogInfo(context,
            message:
                'Kamu harus mengerjakan paket ${paketSebelumnya.kodePaket} '
                'sebelum bisa mengerjakan paket ${paketTO.kodePaket} Sobat');
      } else {
        gShowBottomDialog(
          context,
          title: 'Belum bisa membuka paket ${paketTO.kodePaket}',
          message:
              'Untuk melanjutkan ke paket soal selanjutnya, Silahkan kumpulkan '
              'paket ${paketSebelumnya.kodePaket} dengan nomor urut ${paketSebelumnya.nomorUrut} '
              'terlebih dahulu',
          actions: (controller) => [
            TextButton(
                onPressed: () async => await _kumpulkanPaket(
                      controller: controller,
                      paketTO: paketSebelumnya,
                    ),
                child: Text('Kumpulkan Paket ${paketSebelumnya.kodePaket}'))
          ],
        );
      }
    } else {
      bool bolehMengerjakan = paketSebelumnya == null ||
          paketSebelumnya.isBolehLanjutNomorUrut(
            currentServerTime: serverTime,
            jarakAntarPaket: widget.jarakAntarPaket,
          );

      if (!bolehMengerjakan && !serverTime.isAfter(widget.tanggalBerakhirTO)) {
        String message =
            'Kamu harus menunggu ${widget.jarakAntarPaket} menit setelah '
            'paket ${paketSebelumnya.kodePaket} selesai, sebelum bisa mengerjakan '
            'paket ${paketTO.kodePaket} Sobat.';

        if (paketSebelumnya.tanggalSiswaSubmit != null) {
          message += ' Kamu baru bisa mulai mengerjakan pukul '
              '${paketSebelumnya.tanggalSiswaSubmit!.add(Duration(minutes: widget.jarakAntarPaket)).hoursMinutesDDMMMYYYY}';
        }

        await gShowBottomDialogInfo(context, message: message);
        return;
      }

      if (kDebugMode) {
        logger.log(
            'PAKET_TO_SCREEN-OnClickPaketListTile: Sudah Kumpulkan : $isSudahDikumpulkan || Deadline >> ${paketTO.deadlinePengerjaan}');
        logger.log(
            'PAKET_TO_SCREEN-OnClickPaketListTile: Waktu Habis : $isWaktuHabis');
        logger.log(
            'PAKET_TO_SCREEN-OnClickPaketListTile: Lewat tanggal akhir : ${serverTime.isAfter(widget.tanggalBerakhirTO)}');
        logger.log(
            'PAKET_TO_SCREEN-OnClickPaketListTile: $serverTime | ${widget.tanggalBerakhirTO}');
        logger.log(
            'PAKET_TO_SCREEN-OnClickPaketListTile: ${paketTO.isPernahMengerjakan} | ${paketTO.kapanMulaiMengerjakan} | ${paketTO.tanggalSiswaSubmit}');
      }

      // if ((isSudahDikumpulkan || isWaktuHabis) &&
      //     !serverTime.isAfter(widget.tanggalBerakhirTO)) {
      //   gShowBottomDialogInfo(context,
      //       dialogType: DialogType.info,
      //       title: 'Belum Boleh Melihat Solusi',
      //       message:
      //           'Masa tryout belum berakhir, Kamu baru bisa melihat solusi setelah '
      //           '${widget.tanggalBerakhirTO.hoursMinutesDDMMMYYYY}');
      //   return;
      // }

      bool isSiapTryout = isPernahMengerjakan;

      if (!isPernahMengerjakan && !isWaktuHabis) {
        isSiapTryout = await gShowBottomDialog(
          ctx,
          title: 'Konfirmasi mulai mengerjakan Tryout-${paketTO.kodePaket}',
          message:
              'Pastikan kamu sudah siap dan dalam kondisi nyaman untuk mengerjakan Tryout-${paketTO.kodePaket}. '
              'Setelah Tryout-${paketTO.kodePaket} dimulai, kamu tidak dapat keluar dari halaman pengerjaan sebelum '
              'waktu habis / sudah mengumpulkan jawaban. Siap mengerjakan sekarang Sobat?',
          dialogType: DialogType.warning,
        );
      }

      if (isSiapTryout || isWaktuHabis) {
        _onClickPaketTO(
          paketTO: paketTO,
          paketSelanjutnya: paketSelanjutnya,
          isTOBerakhir: serverTime.isAfter(widget.tanggalBerakhirTO),
          hanyaBolehKumpulkan: paketTO.tanggalSiswaSubmit == null &&
              paketTO.isPernahMengerjakan &&
              serverTime.isAfter(
                  paketTO.deadlinePengerjaan ?? widget.tanggalBerakhirTO) &&
              serverTime.isBefore(
                  widget.tanggalBerakhirTO.add(const Duration(hours: 1))),
        );
      }
    }
  }

  Future<void> _onClickLihatKisiKisi(String kodePaket) async {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        childWidget ??= KisiKisiWidget(kodePaket: kodePaket);
        return childWidget!;
      },
    );
  }

  Widget _buildPaketTOContent(DateTime serverTime) {
    return Selector<TOBProvider, List<PaketTO>>(
      selector: (_, tob) => tob.getListPaketTOByKodeTOB(widget.kodeTOB),
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

          shouldRebuild = paket.totalWaktu != prevPaket.totalWaktu ||
              paket.jumlahSoal != prevPaket.jumlahSoal ||
              paket.idJenisProduk != prevPaket.idJenisProduk ||
              paket.nomorUrut != prevPaket.nomorUrut ||
              paket.kapanMulaiMengerjakan != prevPaket.kapanMulaiMengerjakan ||
              paket.deadlinePengerjaan != prevPaket.deadlinePengerjaan ||
              paket.tanggalSiswaSubmit != prevPaket.tanggalSiswaSubmit ||
              paket.nomorUrut != prevPaket.nomorUrut ||
              paket.isWaktuHabis != prevPaket.isWaktuHabis ||
              paket.isBlockingTime != prevPaket.isBlockingTime ||
              paket.isPernahMengerjakan != prevPaket.isPernahMengerjakan ||
              paket.isSelesai != prevPaket.isSelesai ||
              paket.isTeaser != prevPaket.isTeaser;
        }

        return shouldRebuild;
      }),
      builder: (_, listPaketTOB, emptyWidget) => FutureBuilder<void>(
          future: _onRefreshPaketTO(false),
          builder: (context, snapshot) {
            final bool isLoading =
                snapshot.connectionState == ConnectionState.waiting ||
                    context.select<TOBProvider, bool>(
                        (paket) => paket.isLoadingPaketTO);

            if (isLoading) {
              return const ShimmerListTiles(isWatermarked: true);
            }

            if (widget.isFormatTOMerdeka) {
              if (kDebugMode) {
                logger.log(
                    'PAKET_TO_SCREEN-FutureBuilder: List Pilihan >> ${widget.daftarMataUjiPilihan}');
                logger.log(
                    'PAKET_TO_SCREEN-FutureBuilder: List Paket >> $listPaketTOB');
              }

              // Hapus daftar paket di luar dari mata uji pilihan
              listPaketTOB.removeWhere((paketTO) {
                bool isPilihan = !paketTO.isWajib;
                bool isDipilih = widget.daftarMataUjiPilihan.any((mataUji) =>
                    paketTO.idKelompokUjian == mataUji.idKelompokUjian);

                if (kDebugMode) {
                  logger.log(
                      'PAKET_TO_SCREEN-FutureBuilder: Paket ${paketTO.kodePaket}-${paketTO.idKelompokUjian}'
                      '>> Pilihan($isPilihan) | Dipilih($isDipilih)');
                }

                return isPilihan && !isDipilih;
              });

              if (kDebugMode) {
                logger.log(
                    'PAKET_TO_SCREEN-FutureBuilder: List Paket (removed)>> $listPaketTOB');
              }
            }

            var refreshWidget = CustomSmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefreshPaketTO,
              isDark: true,
              child: (listPaketTOB.isEmpty)
                  ? emptyWidget!
                  : _buildListPaketTO(serverTime, listPaketTOB),
            );

            return (listPaketTOB.isEmpty)
                ? refreshWidget
                : WatermarkWidget(child: refreshWidget);
          }),
      child: BasicEmpty(
          isLandscape: !context.isMobile,
          imageUrl: 'ilustrasi_data_not_found.png'.illustration,
          title: 'Oops',
          subTitle: 'Paket Belum Tersedia',
          emptyMessage:
              'Belum ada Paket pada TOB ${widget.kodeTOB}-${widget.namaTOB}'),
    );
  }

  Container _buildPesanTryoutSelesai() => Container(
        margin: EdgeInsets.only(
            top: context.dp(14), left: context.dp(12), right: context.dp(12)),
        padding: EdgeInsets.symmetric(
            horizontal: context.dp(14), vertical: context.dp(12)),
        decoration: BoxDecoration(
          color: context.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
              image: AssetImage('assets/img/information.png'),
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              opacity: 0.2),
        ),
        child: RichText(
          textScaleFactor: context.textScale12,
          text: TextSpan(
            text: (_serverTime.isAfter(widget.tanggalBerakhirTO))
                ? 'TryOut ini sudah selesai Sobat!\n'
                : (!widget.isTOBRunning)
                    ? 'TryOut ini belum dimulai Sobat!\n'
                    : 'Tidak memenuhi EMWA prasyarat!\n',
            style: context.text.labelLarge
                ?.copyWith(color: context.onPrimaryContainer),
            children: [
              TextSpan(
                text: (_serverTime.isAfter(widget.tanggalBerakhirTO))
                    ? 'Kamu hanya bisa melihat laporan dan solusi dari Tryout ini. '
                        'Klik paket untuk melihat solusi'
                    : (!widget.isTOBRunning)
                        ? '${widget.namaTOB} baru akan dimulai pada $_displayTOBMulai. '
                            'Yuk lihat kisi-kisi dan persiapkan diri kamu untuk '
                            'raih hasil yang maksimal!'
                        : 'Kamu tidak bisa mengerjakan TryOut ini karena '
                            'tidak memenuhi syarat kelulusan Empati Wajib Sobat.',
                style: context.text.labelSmall?.copyWith(
                    color: context.onPrimaryContainer,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      );

  Widget _buildListPaketTO(DateTime serverTime, List<PaketTO> listPaketTO) =>
      ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
              top: context.dp(10),
              bottom: context.dp(30),
              left: context.dp(12),
              right: context.dp(12)),
          itemBuilder: (_, index) {
            PaketTO paketTO = listPaketTO[index];
            String namaMataUji = Constant
                    .kInitialKelompokUjian[paketTO.idKelompokUjian]?['nama'] ??
                'Undefined';
            bool isPernahMengerjakan = paketTO.deadlinePengerjaan != null;
            bool isSudahDikumpulkan =
                paketTO.tanggalSiswaSubmit != null || paketTO.isSelesai;
            bool isTOBBerakhir = serverTime.isAfter(widget.tanggalBerakhirTO);
            bool isWaktuHabis =
                (isTOBBerakhir) ? isTOBBerakhir : paketTO.isWaktuHabis;

            return ListTile(
              // onLongPress: () => showDetailHasil(context, listPaketTO[index]),
              onTap: () async => await _onClickPaketListTile(
                  paketTO: paketTO,
                  paketSebelumnya: (index > 0) ? listPaketTO[index - 1] : null,
                  paketSelanjutnya: (index < listPaketTO.length - 1)
                      ? listPaketTO[index + 1]
                      : null,
                  isPernahMengerjakan: isPernahMengerjakan,
                  isSudahDikumpulkan: isSudahDikumpulkan,
                  isWaktuHabis: isWaktuHabis),
              contentPadding: EdgeInsets.symmetric(horizontal: context.dp(6)),
              title: RichText(
                textScaleFactor: context.textScale12,
                text: TextSpan(
                    semanticsLabel: 'paket-to-item-title',
                    text: '${paketTO.kodePaket} ',
                    style: context.text.titleMedium,
                    children: [
                      TextSpan(
                          semanticsLabel: 'paket-to-item-title-span',
                          text: '(${paketTO.jumlahSoal} soal)',
                          style: context.text.bodySmall)
                    ]),
              ),
              subtitle: (!isSudahDikumpulkan && isTOBBerakhir)
                  ? Text(
                      'Kamu tidak ${isPernahMengerjakan ? 'mengumpulkan' : 'mengerjakan'} paket ini sobat',
                      semanticsLabel: 'paket-to-item-sub-title',
                      style: context.text.bodySmall)
                  : (isPernahMengerjakan || isSudahDikumpulkan)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!paketTO.isWajib)
                              Text(namaMataUji, style: context.text.bodySmall),
                            Text(
                                (!isSudahDikumpulkan && isWaktuHabis)
                                    ? 'Kamu belum mengumpulkan paket ini sobat.'
                                    : 'Durasi: ${paketTO.displayDurasiLengkap}',
                                semanticsLabel:
                                    'paket-to-item-sub-title-duration',
                                style: context.text.bodySmall),
                            Text(
                                (!isSudahDikumpulkan && !isWaktuHabis)
                                    ? 'Batas Pengerjaan:\n${paketTO.displayDeadlinePengerjaan}'
                                    : (isSudahDikumpulkan)
                                        ? 'Dikumpulkan Pada:\n${paketTO.displayTanggalSiswaSubmit}'
                                        : 'Batas Pengumpulan:\n$_displayTOBBerakhir',
                                semanticsLabel: 'paket-to-item-sub-title-date',
                                style: context.text.bodySmall),
                          ],
                        )
                      : (!paketTO.isWajib)
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(namaMataUji,
                                    style: context.text.bodySmall),
                                Text('Durasi: ${paketTO.displayDurasiLengkap}',
                                    semanticsLabel:
                                        'paket-to-item-sub-title-duration',
                                    style: context.text.bodySmall),
                              ],
                            )
                          : Text('Durasi: ${paketTO.displayDurasiLengkap}',
                              semanticsLabel: 'paket-to-item-sub-title',
                              style: context.text.bodySmall),
              leading: _buildLeadingInfo(
                  isSudahDikumpulkan, isWaktuHabis, isTOBBerakhir, paketTO),
              trailing: (widget.isBolehLihatKisiKisi)
                  ? TextButton(
                      onPressed: () async =>
                          await _onClickLihatKisiKisi(paketTO.kodePaket),
                      child: Text(
                          (context.isMobile)
                              ? 'Lihat\nKisi-Kisi'
                              : 'Lihat Kisi-Kisi',
                          textAlign: TextAlign.center))
                  : null,
            );
          },
          separatorBuilder: (_, __) => const Divider(),
          itemCount: listPaketTO.length);

  Widget _buildLeadingInfo(bool isSudahDikumpulkan, bool isWaktuHabis,
      bool isTOBBerakhir, PaketTO paketTO) {
    final leadingWidget = Container(
      width: context.dp((!isSudahDikumpulkan && isWaktuHabis && !isTOBBerakhir)
          ? 64
          : isSudahDikumpulkan
              ? 70
              : 74),
      padding: EdgeInsets.symmetric(
          vertical:
              min(10, context.dp((isSudahDikumpulkan || isWaktuHabis) ? 8 : 4)),
          horizontal:
              min(6, context.dp((isSudahDikumpulkan || isWaktuHabis) ? 0 : 4))),
      decoration: BoxDecoration(
        color: (isSudahDikumpulkan)
            ? Palette.kSuccessSwatch[500]
            : (isWaktuHabis && !isTOBBerakhir)
                ? Palette.kSecondarySwatch[600]
                : (isTOBBerakhir)
                    ? context.primaryColor
                    : null,
        border: (isSudahDikumpulkan || isWaktuHabis)
            ? null
            : Border.all(color: context.tertiaryColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          (isSudahDikumpulkan)
              ? const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white70)
              : (isWaktuHabis)
                  ? Icon(Icons.cancel_outlined, color: context.onPrimary)
                  : Text('nomor\nurut',
                      textAlign: TextAlign.center,
                      style: context.text.labelSmall
                          ?.copyWith(color: context.tertiaryColor)),
          Text(
            '${paketTO.nomorUrut}',
            textAlign: TextAlign.center,
            style: context.text.titleLarge?.copyWith(
                color: (isSudahDikumpulkan)
                    ? Colors.white70
                    : (isWaktuHabis)
                        ? context.onPrimary
                        : context.tertiaryColor),
          ),
        ],
      ),
    );

    return leadingWidget;
  }
}
