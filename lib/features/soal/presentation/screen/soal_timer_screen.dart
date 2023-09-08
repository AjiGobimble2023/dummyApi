// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../../../../core/shared/widget/html/custom_html_widget.dart';
import '../widget/solusi_widget.dart';
import '../widget/sobat_tips_widget.dart';
import '../widget/soal_countdown_timer.dart';
import '../widget/jenis_jawaban/jawaban_essay.dart';
import '../widget/jenis_jawaban/jawaban_essay_majemuk.dart';
import '../widget/jenis_jawaban/pilihan_berganda_tabel.dart';
import '../widget/jenis_jawaban/pilihan_ganda_berbobot.dart';
import '../widget/jenis_jawaban/pilihan_berganda_kompleks.dart';
import '../widget/jenis_jawaban/pilihan_berganda_bercabang.dart';
import '../widget/jenis_jawaban/pilihan_berganda_sederhana.dart';
import '../widget/jenis_jawaban/pilihan_berganda_memasangkan.dart';
import '../widget/jenis_jawaban/pilihan_berganda_complex_terbatas.dart';
import '../../service/local/soal_service_local.dart';
import '../../module/timer_soal/presentation/provider/tob_provider.dart';
import '../../../video/presentation/widget/video_player_card.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/util/platform_channel.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/screen/custom_will_pop_scope.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/widget/html/widget_from_html.dart';
import '../../../../core/shared/widget/watermark/watermark_widget.dart';

class SoalTimerScreen extends StatefulWidget {
  final String kodeTOB;
  final String kodePaket;
  final int idJenisProduk;
  final String namaJenisProduk;

  /// [waktuPengerjaan] dalam satuan menit.
  final int waktuPengerjaan;

  /// [tanggalSiswaSubmit] merupakan tanggal kapan siswa submit / kumpulkan.
  /// Di perlukan untuk keperluan remedial GOA.
  final DateTime? tanggalSiswaSubmit;

  /// [tanggalSelesai] merupakan tanggal seharusnya siswa selesai mengerjakan.
  final DateTime? tanggalSelesai;

  /// [tanggalKedaluwarsaTOB] merupakan tanggal berakhirnya masa TOB.
  final DateTime tanggalKedaluwarsaTOB;

  /// [isBlockingTime] true maka button kumpulkan hanya akan aktif saat waktu habis.<br>
  /// Button pindah mapel juga tidak akan aktif.
  final bool isBlockingTime;

  /// [isPernahMengerjakan] true maka jenis start: lanjutan, jika false maka jenis start: awal.
  final bool isPernahMengerjakan;

  /// [isRandom] true maka acak urutan soal.
  final bool isRandom;

  final bool isRemedialGOA;
  final bool isBolehLihatSolusi;

  const SoalTimerScreen({
    Key? key,
    required this.kodeTOB,
    required this.kodePaket,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.waktuPengerjaan,
    this.tanggalSelesai,
    this.tanggalSiswaSubmit,
    required this.tanggalKedaluwarsaTOB,
    required this.isBlockingTime,
    required this.isPernahMengerjakan,
    required this.isRandom,
    required this.isBolehLihatSolusi,
    required this.isRemedialGOA,
  }) : super(key: key);

  @override
  State<SoalTimerScreen> createState() => _SoalTimerScreenState();
}

class _SoalTimerScreenState extends State<SoalTimerScreen> {
  final _scrollController = ScrollController();
  final _nomorSoalScrollController = ScrollController();
  late final NavigatorState _navigator = Navigator.of(context);
  final CountdownController _countdownController =
      CountdownController(autoStart: true);

  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();
  late final TOBProvider _tobProvider = context.watch<TOBProvider>();

  // DefaultFlashController? _previousDialog;
  bool get _isLoading =>
      _tobProvider.isLoadingSoal || !_tobProvider.isSoalExist;

  /// Untuk e-GOA(12) dan e-VAK(65) tidak boleh melihat solusi.
  late bool isBolehLihatSolusi = widget.isBolehLihatSolusi &&
      widget.idJenisProduk != 12 &&
      widget.idJenisProduk != 65;

  late final String _displayBatasPengumpulan = DataFormatter.dateTimeToString(
      widget.tanggalKedaluwarsaTOB.add(const Duration(hours: 1)),
      '[HH:mm] dd MMM yyyy');

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1300)).then((value) =>
        PlatformChannel.setSecureScreen(Constant.kRouteSoalTimerScreen));

    if (!_authOtpProvider.isLogin || _authOtpProvider.isOrtu) {
      SoalServiceLocal().openJawabanBox();
    }
    _getSoal();
    super.initState();
  }

  @override
  void dispose() {
    PlatformChannel.setSecureScreen('POP', true);
    if (!_authOtpProvider.isLogin || _authOtpProvider.isOrtu) {
      SoalServiceLocal().closeJawabanBox();
    }
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) =>
      (mounted) ? super.setState(() => fn()) : fn();

  @override
  Widget build(BuildContext context) {
    PlatformChannel.setSecureScreen(Constant.kRouteSoalTimerScreen);

    if (kDebugMode) {
      logger.log('SOAL_TIMER_SCREEN-Build: $isBolehLihatSolusi | | ');
    }
    // TODO: coba olah durasi-nya dari sini. dan edit soal_countdown_timer.dart
    return CustomWillPopScope(
      swipeSensitivity: (widget.isBolehLihatSolusi) ? 12 : 20,
      onWillPop: () async {
        if (!widget.isBolehLihatSolusi && !_isLoading) {
          _bottomDialog();
        }
        return Future.value(widget.isBolehLihatSolusi);
      },
      onDragRight: () {
        if (widget.isBolehLihatSolusi || _isLoading) {
          _navigator.pop();
        } else {
          _bottomDialog();
        }
      },
      child: Scaffold(
        backgroundColor: context.primaryColor,
        appBar: (context.isMobile) ? _buildAppBar(_isLoading) : null,
        body: ResponsiveBuilder(
          mobile: Container(
            width: context.dw,
            height: double.infinity,
            decoration: BoxDecoration(
                color: context.background,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24))),
            child: WatermarkWidget(
              child: _buildListViewBody(context),
            ),
          ),
          tablet: Row(
            children: [
              Expanded(
                flex: (context.dw > 1100) ? 3 : 4,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildAppBar
                        _buildAppBarTitle(_isLoading),
                        const SizedBox(height: 12),
                        if (!_isLoading && widget.isBolehLihatSolusi)
                          Row(
                            children: _buildTingkatKesulitanSoal(
                                _tobProvider.soal.tingkatKesulitan),
                          ),
                        if (_isLoading)
                          ShimmerWidget.rectangle(
                            width: min(100, context.dp(82)),
                            height: min(32, context.dp(24)),
                          ),
                        if (!_isLoading && !widget.isBolehLihatSolusi)
                          Transform.translate(
                            offset: const Offset(-14, 0),
                            child: SoalCountdownTimer(
                              onEndTimer: _onEndTimer,
                              kodePaket: widget.kodePaket,
                              isBlockingTime: widget.isBlockingTime,
                              countdownController: _countdownController,
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: _buildSubmitButton(_isLoading),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              color: context.onPrimary,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Scrollbar(
                                controller: _nomorSoalScrollController,
                                thickness: 8,
                                trackVisibility: true,
                                thumbVisibility: true,
                                radius: const Radius.circular(14),
                                child: _buildDaftarNomorSoal(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  color: context.onPrimary,
                  child: Stack(
                    children: [
                      _buildListViewBody(context),
                      Positioned(
                        bottom: 18,
                        right: 24,
                        left: 24,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!_isLoading && isBolehLihatSolusi)
                              _buildSobatTipsButton(),
                            if (!_isLoading && isBolehLihatSolusi)
                              const SizedBox(height: 14),
                            _buildBottomNavBar(_isLoading),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            (context.isMobile) ? _buildBottomNavBar(_isLoading) : null,
        floatingActionButton: (!context.isMobile)
            ? null
            : (!_isLoading && isBolehLihatSolusi)
                ? _buildSobatTipsButton()
                : null,
      ),
    );
  }

  ListView _buildListViewBody(BuildContext context) {
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: min(24, context.dp(16)),
        right: min(24, context.dp(16)),
        top: min(10, context.dp(6)),
        bottom: context.dp(16),
      ),
      children: (_isLoading)
          ? _buildLoadingWidget(context)
          : [
              _buildRatingDanRagu(),
              _buildWacanaWidget(),
              _buildSoalWidget(),
              _buildJawabanWidget(),
              if (!isBolehLihatSolusi) SizedBox(height: context.dp(40)),
              if (isBolehLihatSolusi && !_isLoading)
                SolusiWidget(
                  idSoal: _tobProvider.soal.idSoal,
                  tipeSoal: _tobProvider.soal.tipeSoal,
                  idVideo: _tobProvider.soal.idVideo,
                  kunciJawaban: _tobProvider.soal.kunciJawaban,
                  accessFrom: AccessVideoCardFrom.videoSolusi,
                ),
            ],
    );
  }

  /// This function is triggered when the user presses the back-to-top button
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// NOTE: kumpulan function
  /// [_kumpulkanJawaban] merupakan fungsi untuk mengumpulkan semua jawaban siswa,
  /// jika soal belum dikerjakan, maka akan dianggap kosong.
  Future<void> _kumpulkanJawaban() async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);

    if (widget.idJenisProduk == 12 || widget.idJenisProduk == 80) {
      await _tobProvider.kumpulkanJawabanGOA(
        tahunAjaran: _authOtpProvider.tahunAjaran,
        tingkatKelas: _authOtpProvider.userData?.tingkatKelas ??
            _authOtpProvider.tingkatKelas,
        idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
            _authOtpProvider.idSekolahKelas.value ??
            '14',
        idKota: _authOtpProvider.userData?.idKota ?? '',
        idGedung: _authOtpProvider.userData?.idGedung ?? '',
        noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
        tipeUser: _authOtpProvider.userData?.siapa,
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: widget.kodeTOB,
        kodePaket: widget.kodePaket,
      );
    } else {
      await _tobProvider.updatePesertaTO(
        tahunAjaran: _authOtpProvider.tahunAjaran,
        tingkatKelas: _authOtpProvider.userData?.tingkatKelas ??
            _authOtpProvider.tingkatKelas,
        idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
            _authOtpProvider.idSekolahKelas.value ??
            '14',
        noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
        tipeUser: _authOtpProvider.userData?.siapa,
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: widget.kodeTOB,
        kodePaket: widget.kodePaket,
      );
    }

    // await _tobProvider.kumpulkanJawabanTO(
    //   tahunAjaran: _authOtpProvider.tahunAjaran,
    //   tingkatKelas: _authOtpProvider.userData?.tingkatKelas ??
    //       _authOtpProvider.tingkatKelas,
    //   idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
    //       _authOtpProvider.idSekolahKelas.value ??
    //       '14',
    //   noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
    //   tipeUser: _authOtpProvider.userData?.siapa,
    //   idJenisProduk: widget.idJenisProduk,
    //   namaJenisProduk: widget.namaJenisProduk,
    //   kodeTOB: widget.kodeTOB,
    //   kodePaket: widget.kodePaket,
    // );

    completer.complete();
    // await Future.delayed(const Duration(seconds: 2, milliseconds: 300));
    await Future.delayed(gDelayedNavigation);
    _navigator.pop();
  }

  Future<void> _raguRaguToggle(bool? isRagu) async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    await _tobProvider.toggleRaguRagu(
      tahunAjaran: _authOtpProvider.tahunAjaran,
      idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
          _authOtpProvider.idSekolahKelas.value ??
          '14',
      noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
      tipeUser: _authOtpProvider.userData?.siapa,
      kodePaket: widget.kodePaket,
    );
    completer.complete();
  }

  Future<void> _onClickNextKelompokUjian() async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);

    await _tobProvider.jumpToSoalNomor(
        _tobProvider.getMataUjiSelanjutnya(widget.kodePaket)!.indexSoalPertama);

    _scrollToTop();
    completer.complete();
  }

  void _blockingTimeNextKelompokUjian() {
    var listDetailBundel =
        _tobProvider.getListDetailWaktuByKodePaket(widget.kodePaket);
    var mataUjiSekarang = listDetailBundel.isNotEmpty
        ? listDetailBundel[_tobProvider.indexCurrentMataUji]
        : null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tunggu Mata Uji ${mataUjiSekarang?.namaKelompokUjian ?? 'Undefined'} selesai ya Sobat!',
          style: context.text.bodyMedium
              ?.copyWith(color: context.onPrimaryContainer),
        ),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: context.primaryContainer,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(context.dp(16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  /// [_onClickSobatTips] akan menampilkan List Bab dan Sub Bab yang terkait dengan soal.
  Future<void> _onClickSobatTips(String idSoal, String idBundel) async {
    bool isBeliLengkap = _authOtpProvider.isProdukDibeliSiswa(59);
    bool isBeliSingkat = _authOtpProvider.isProdukDibeliSiswa(97);
    bool isBeliRingkas = _authOtpProvider.isProdukDibeliSiswa(98);

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        childWidget ??= SobatTipsWidget(
          isBeliTeori: isBeliLengkap || isBeliSingkat || isBeliRingkas,
          getSobatTips: _tobProvider.getSobatTips(
            idSoal: idSoal,
            idBundel: idBundel,
            isBeliLengkap: isBeliLengkap,
            isBeliSingkat: isBeliSingkat,
            isBeliRingkas: isBeliRingkas,
          ),
        );
        return childWidget!;
      },
    );
  }

  void _getSoal({bool isRefresh = false}) {
    // Hack agar terhindar dari unmounted
    Future.delayed(const Duration(milliseconds: 300)).then((_) async {
      await context.read<TOBProvider>().getDaftarSoalTO(
            isRefresh: isRefresh,
            kodeTOB: widget.kodeTOB,
            kodePaket: widget.kodePaket,
            idJenisProduk: widget.idJenisProduk,
            namaJenisProduk: widget.namaJenisProduk,
            isAwalMulai: widget.tanggalSelesai == null,
            tanggalSelesai: widget.tanggalSelesai,
            tanggalSiswaSubmit: widget.tanggalSiswaSubmit,
            tanggalKedaluwarsaTOB: widget.tanggalKedaluwarsaTOB,
            totalWaktu: widget.waktuPengerjaan,
            isBlockingTime: widget.isBlockingTime,
            isRandom: widget.isRandom,
            isTOBBerakhir: widget.isBolehLihatSolusi ||
                DateTime.now()
                    .serverTimeFromOffset
                    .isAfter(widget.tanggalKedaluwarsaTOB),
            tahunAjaran: _authOtpProvider.tahunAjaran,
            idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
                _authOtpProvider.idSekolahKelas.value ??
                '14',
            noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
            tipeUser: _authOtpProvider.userData?.siapa,
            isRemedialGOA: widget.isRemedialGOA,
          );
    });
  }

  Future<void> _setTempJawaban(dynamic jawabanSiswa) async {
    await _tobProvider.setTempJawaban(
      tahunAjaran: _authOtpProvider.tahunAjaran,
      idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
          _authOtpProvider.idSekolahKelas.value ??
          '14',
      noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
      tipeUser: _authOtpProvider.userData?.siapa,
      kodePaket: widget.kodePaket,
      jenisProduk: widget.namaJenisProduk,
      jawabanSiswa: jawabanSiswa,
    );
  }

  void _onClickNomorSoal() {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(maxHeight: context.dh * 0.86),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        childWidget ??= _buildDaftarNomorSoal();
        return childWidget!;
      },
    );
  }

  SingleChildScrollView _buildDaftarNomorSoal() {
    return SingleChildScrollView(
      controller: _nomorSoalScrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: min(18, context.dp(17)),
          vertical: min(24, context.dp(24)),
        ),
        child: Consumer<TOBProvider>(
          builder: (context, tobProvider, _) => Wrap(
            spacing: min(18, context.dp(16)),
            runSpacing: min(18, context.dp(16)),
            children: List.generate(
              tobProvider.jumlahSoal,
              (index) {
                Color warnaNomor = context.onBackground;
                Color warnaNomorContainer = context.background;
                Color warnaBorder = context.onBackground;
                int nomorSoal =
                    tobProvider.getSoalByIndex(index).nomorSoalSiswa;
                int indexNomorSoal = tobProvider.indexSoal;

                // Bool value
                bool isRagu = tobProvider.getSoalByIndex(index).isRagu;
                bool isSudahDikumpulkan =
                    tobProvider.getSoalByIndex(index).sudahDikumpulkan ||
                        DateTime.now()
                            .serverTimeFromOffset
                            .isAfter(widget.tanggalKedaluwarsaTOB);

                if (isRagu && !isSudahDikumpulkan) {
                  warnaNomorContainer = Palette.kSecondarySwatch[400]!;
                  warnaBorder = context.secondaryColor;
                }
                if (isSudahDikumpulkan) {
                  warnaNomorContainer = context.disableColor;
                  warnaNomor = context.disableColor;
                }
                if (index == indexNomorSoal) {
                  warnaNomor = context.onTertiary;
                  warnaNomorContainer = context.tertiaryColor;
                }

                var listDetailBundel =
                    tobProvider.getListDetailWaktuByKodePaket(widget.kodePaket);
                var mataUjiSekarang = listDetailBundel.isNotEmpty
                    ? listDetailBundel[tobProvider.indexCurrentMataUji]
                    : null;

                bool isBolehPindahSoal =
                    !widget.isBlockingTime || widget.isBolehLihatSolusi;

                logger.log('TIMER SOAL-ClickNomor: Nomor >> $nomorSoal');
                logger.log(
                    'TIMER SOAL-ClickNomor: blocking time >> ${widget.isBlockingTime}');
                logger.log(
                    'TIMER SOAL-ClickNomor: boleh lihat solusi >> ${widget.isBlockingTime}');
                logger.log(
                    'TIMER SOAL-ClickNomor: boleh pindah >> $isBolehPindahSoal');

                if (widget.isBlockingTime &&
                    mataUjiSekarang != null &&
                    !widget.isBolehLihatSolusi) {
                  isBolehPindahSoal =
                      index >= mataUjiSekarang.indexSoalPertama &&
                          index <= mataUjiSekarang.indexSoalTerakhir;

                  if (!isBolehPindahSoal) {
                    warnaNomorContainer = context.disableColor;
                    warnaNomor = context.disableColor;
                  }
                }

                return InkWell(
                  onTap: () {
                    if (isBolehPindahSoal) {
                      tobProvider.jumpToSoalNomor(index);

                      if (context.isMobile) {
                        Navigator.pop(context);
                      }

                      _scrollToTop();
                    } else {
                      if (context.isMobile) {
                        Navigator.pop(context);
                      }
                      ScaffoldMessenger.of(gNavigatorKey.currentState!.context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              (mataUjiSekarang != null &&
                                      index < mataUjiSekarang.indexSoalPertama)
                                  ? 'Mata Uji ${listDetailBundel[tobProvider.indexCurrentMataUji - 1].namaKelompokUjian} sudah selesai sobat!'
                                  : 'Tunggu Mata Uji ${mataUjiSekarang?.namaKelompokUjian ?? 'Undefined'} selesai ya Sobat!',
                              style: context.text.bodyMedium
                                  ?.copyWith(color: context.onPrimaryContainer),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: context.primaryContainer,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(context.dp(16)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        );
                    }
                  },
                  borderRadius: BorderRadius.circular(3000),
                  child: Container(
                      width: min(48, context.dp(46)),
                      height: min(48, context.dp(46)),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(min(6, context.dp(4))),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: warnaBorder),
                          color: warnaNomorContainer),
                      child: FittedBox(
                        child: Text('$nomorSoal',
                            style: TextStyle(color: warnaNomor)),
                      )),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onEndTimer() async {
    if (!widget.isBolehLihatSolusi) {
      bool kumpulkanSoal = !widget.isBlockingTime ||
          context.read<TOBProvider>().getMataUjiSelanjutnya(widget.kodePaket) ==
              null;

      if (!kumpulkanSoal) {
        _tobProvider.setNextMataUjiBlockingTime(kodePaket: widget.kodePaket);
        _countdownController.restart();
        _countdownController.start();
      } else {
        ScaffoldMessenger.of(gNavigatorKey.currentState!.context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Yaah waktu sudah habis Sobat, jawaban kamu akan dikumpulkan secara otomatis.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.onSecondary),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: context.secondaryColor,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(context.dp(16)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          );

        await _kumpulkanJawaban();
      }
    }
  }

  List<Widget> _buildLoadingWidget(BuildContext context) => [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerWidget.rounded(
                width: context.dp(120),
                height: context.dp(24),
                borderRadius: BorderRadius.circular(12)),
            ShimmerWidget.rounded(
                width: context.dp(68),
                height: context.dp(24),
                borderRadius: BorderRadius.circular(12)),
          ],
        ),
        SizedBox(height: context.dp(12)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(240),
            borderRadius: BorderRadius.circular(24)),
        SizedBox(height: context.dp(24)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(52),
            borderRadius: BorderRadius.circular(12)),
        SizedBox(height: context.dp(12)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(52),
            borderRadius: BorderRadius.circular(12)),
        SizedBox(height: context.dp(12)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(52),
            borderRadius: BorderRadius.circular(12)),
        SizedBox(height: context.dp(12)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(52),
            borderRadius: BorderRadius.circular(12)),
        SizedBox(height: context.dp(12)),
      ];

  /// NOTE: kumpulan Widget
  AppBar _buildAppBar(bool isLoading) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: (context.isMobile) ? 60 : 120,
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      leadingWidth: context.dp(18),
      leading: SizedBox(width: context.dp(18)),
      title: _buildAppBarTitle(isLoading),
      bottom: _buildTimerDanNomorSoal(isLoading),
      actions: [
        Padding(
          padding: EdgeInsets.only(
              top: context.dp(12), left: context.dp(12), right: context.dp(12)),
          child: _buildSubmitButton(isLoading),
        )
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    bool isBolehKumpulkan = !isBolehLihatSolusi &&
        DateTime.now().serverTimeFromOffset.isBefore(
            widget.tanggalKedaluwarsaTOB.add(const Duration(hours: 1)));

    return (isLoading)
        ? ShimmerWidget.rounded(
            width: (context.isMobile) ? context.dp(100) : double.infinity,
            height: min(42, context.dp(32)),
            borderRadius: BorderRadius.circular(context.dp(8)),
          )
        : ElevatedButton(
            onPressed: (isBolehKumpulkan &&
                    _tobProvider.getMataUjiSelanjutnya(widget.kodePaket) ==
                        null)
                ? () async {
                    bool isBolehKumpulkan = !isBolehLihatSolusi &&
                        DateTime.now().serverTimeFromOffset.isBefore(widget
                            .tanggalKedaluwarsaTOB
                            .add(const Duration(hours: 1)));

                    if (!isBolehKumpulkan) {
                      _bottomDialog(
                          title: 'Batas Pengumpulan Sudah Lewat',
                          message:
                              'Kamu telah melewati batas waktu pengumpulan Sobat. '
                              'Pengumpulan hanya boleh dilakukan sebelum $_displayBatasPengumpulan');
                    }

                    if (isBolehKumpulkan) {
                      bool kumpulkanConfirmed = await _bottomDialog(
                          title: 'Apakah sobat sudah selesai mengerjakan soal?',
                          message:
                              'Kumpulkan jawaban berarti seluruh jawaban akan dikumpulkan, '
                              'soal-soal yang belum dikerjakan akan dianggap kosong. '
                              'Kumpulkan sekarang?',
                          actions: (controller) => [
                                TextButton(
                                    onPressed: () => controller.dismiss(false),
                                    style: TextButton.styleFrom(
                                        foregroundColor: context.onBackground),
                                    child: const Text('Nanti Saja')),
                                TextButton(
                                    onPressed: () => controller.dismiss(true),
                                    child: const Text('Kumpulkan')),
                              ]);
                      if (kumpulkanConfirmed) {
                        await _kumpulkanJawaban();
                      }
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.secondaryColor,
              foregroundColor: context.onSecondary,
              minimumSize: (context.isMobile)
                  ? Size(context.dp(114), context.dp(64))
                  : null,
              padding: (context.isMobile)
                  ? null
                  : const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              textStyle: context.text.labelLarge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dp(8)),
              ),
            ),
            child: const Text('Kumpulkan', textAlign: TextAlign.center),
          );
  }

  Column _buildAppBarTitle(bool isLoading) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (context.isMobile) const SizedBox(height: 14),
          Text('Mata Uji Saat Ini',
              style:
                  context.text.labelSmall?.copyWith(color: context.onPrimary)),
          (isLoading)
              ? ShimmerWidget.rectangle(
                  width: min(78, context.dp(68)),
                  height: min(30, context.dp(18)),
                )
              : Text(_tobProvider.soal.namaKelompokUjian,
                  style: context.text.labelLarge?.copyWith(
                      color: context.onPrimary, fontWeight: FontWeight.bold))
        ],
      );

  PreferredSize _buildTimerDanNomorSoal(bool isLoading) => PreferredSize(
        preferredSize: const Size(double.infinity, 38),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dp(12)),
          child: Row(
            children: [
              if (!isLoading && widget.isBolehLihatSolusi)
                ..._buildTingkatKesulitanSoal(
                    _tobProvider.soal.tingkatKesulitan),
              if (isLoading)
                ShimmerWidget.rectangle(
                    width: context.dp(82), height: context.dp(24)),
              if (!isLoading && !widget.isBolehLihatSolusi)
                SoalCountdownTimer(
                  onEndTimer: _onEndTimer,
                  kodePaket: widget.kodePaket,
                  isBlockingTime: widget.isBlockingTime,
                  countdownController: _countdownController,
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: _onClickNomorSoal,
                icon: const Icon(Icons.arrow_drop_down_sharp),
                label: (isLoading)
                    ? ShimmerWidget.rounded(
                        width: context.dp(84),
                        height: context.dp(24),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : Text(
                        'No ${_tobProvider.soal.nomorSoalSiswa}/${_tobProvider.jumlahSoal}'),
                style: TextButton.styleFrom(
                    foregroundColor: context.onPrimary,
                    padding: EdgeInsets.zero,
                    textStyle: context.text.titleMedium,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              )
            ],
          ),
        ),
      );

  Widget _buildRatingDanRagu() => (widget.isBolehLihatSolusi)
      ? SizedBox(height: min(36, context.dp(18)))
      : Row(
          children: [
            ..._buildTingkatKesulitanSoal(_tobProvider.soal.tingkatKesulitan),
            const Spacer(),
            Checkbox(
              value: _tobProvider.soal.isRagu,
              onChanged: _raguRaguToggle,
              activeColor: context.secondaryColor,
              checkColor: context.onSecondary,
            ),
            Text('Ragu', style: context.text.labelLarge),
            SizedBox(width: context.dp(4)),
          ],
        );

  List<Widget> _buildTingkatKesulitanSoal(int tingkatKesulitan) =>
      List.generate(
        5,
        (index) => Icon(
          Icons.star_rounded,
          size: 28,
          color: index < tingkatKesulitan
              ? context.secondaryColor
              : context.disableColor,
        ),
      );

  Widget _buildSoalWidget() {
    final textSoal = _tobProvider.soal.textSoal;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dp(8)),
      child: (textSoal.contains('table'))
          ? WidgetFromHtml(htmlString: textSoal)
          : CustomHtml(htmlString: textSoal),
    );
  }

  Widget _buildWacanaWidget() {
    bool wacanaExist = _tobProvider.soal.wacana != null;

    String? wacana =
        (!wacanaExist) ? null : _tobProvider.soal.wacana!.wacanaText;

    return (!wacanaExist || wacana == null)
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dp(8)),
            child: (wacana.contains('table'))
                ? WidgetFromHtml(htmlString: wacana)
                : CustomHtml(htmlString: wacana),
          );
  }

  //TODO: IdBundel untuk get Sobat tips, tipe soal timer masih belum ditambahkan
  ElevatedButton _buildSobatTipsButton() => ElevatedButton(
        onPressed: () =>
            _onClickSobatTips(_tobProvider.soal.idSoal, "idbundel"),
        style: ElevatedButton.styleFrom(
          elevation: 5,
          textStyle: context.text.labelMedium,
          backgroundColor: context.secondaryColor,
          foregroundColor: context.onSecondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(300)),
          padding: EdgeInsets.only(
              left: min(24, context.dp(12)),
              right: min(16, context.dp(8)),
              top: min(16, context.dp(8)),
              bottom: min(16, context.dp(8))),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sobat Tips'),
            SizedBox(width: min(16, context.dp(8))),
            const Icon(Icons.help_outline_rounded)
          ],
        ),
      );

  Container _buildBottomNavBar(bool isLoading) => Container(
        width: (context.isMobile) ? context.dw : double.infinity,
        padding: (context.isMobile)
            ? EdgeInsets.only(
                top: min(14, context.dp(8)),
                left: min(14, context.dp(8)),
                right: min(14, context.dp(8)),
                bottom:
                    min(14, context.dp(8)) + min(20, context.bottomBarHeight),
              )
            : EdgeInsets.all(min(14, context.dp(8))),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: (context.isMobile) ? null : BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.disableColor,
              blurRadius: 8,
              offset:
                  (context.isMobile) ? const Offset(0, -2) : const Offset(2, 2),
            )
          ],
        ),
        child: Row(
          children: [
            if (isLoading)
              ShimmerWidget.rectangle(
                width:
                    (context.isMobile) ? (context.dw / 2.2) : context.dp(100),
                height: min(42, context.dp(36)),
              ),
            if (!isLoading &&
                _tobProvider.getMataUjiSelanjutnya(widget.kodePaket) != null)
              TextButton(
                onPressed: (widget.isBlockingTime && !widget.isBolehLihatSolusi)
                    ? _blockingTimeNextKelompokUjian
                    : _onClickNextKelompokUjian,
                style:
                    TextButton.styleFrom(foregroundColor: context.onBackground),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (context.isMobile)
                            ? context.dw / 2.2
                            : context.dp(100),
                      ),
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: context.textScale12,
                        text: TextSpan(
                          text: 'Selanjutnya\n',
                          style: context.text.labelMedium,
                          children: [
                            TextSpan(
                                text: _tobProvider
                                    .getMataUjiSelanjutnya(widget.kodePaket)!
                                    .namaKelompokUjian,
                                style: context.text.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded)
                  ],
                ),
              ),
            const Spacer(),
            (isLoading)
                ? ShimmerWidget.rounded(
                    width: context.dp(24),
                    height: context.dp(24),
                    borderRadius: BorderRadius.circular(context.dp(8)),
                  )
                : IconButton(
                    onPressed: (_tobProvider.isFirstSoal)
                        ? null
                        : () {
                            _scrollToTop();
                            _tobProvider.setPrevSoal(
                                kodePaket: widget.kodePaket);
                          },
                    icon: const Icon(Icons.chevron_left_rounded)),
            if (isLoading) const SizedBox(width: 8),
            (isLoading)
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ShimmerWidget.rounded(
                      width: context.dp(24),
                      height: context.dp(24),
                      borderRadius: BorderRadius.circular(context.dp(8)),
                    ),
                  )
                : IconButton(
                    onPressed: (_tobProvider.isLastSoal)
                        ? null
                        : () {
                            _scrollToTop();
                            _tobProvider.setNextSoal(
                                kodePaket: widget.kodePaket);
                          },
                    icon: const Icon(Icons.chevron_right_rounded))
          ],
        ),
      );

  Widget _buildJawabanWidget() {
    if (kDebugMode) {
      logger.log(
          'SOAL_TIMER_SCREEN-BuildJawabanWidget: ${_tobProvider.soal.jawabanSiswa}');
    }
    switch (_tobProvider.soal.tipeSoal) {
      case 'PGB':
        return PilihanGandaBerbobot(
          jsonOpsiJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: _tobProvider.soal.jawabanSiswa,
          kunciJawaban: _tobProvider.soal.kunciJawaban,
          isBolehLihatKunci: isBolehLihatSolusi,
          onClickPilihJawaban: (widget.isBolehLihatSolusi)
              ? null
              : (pilihanJawaban) async => await _setTempJawaban(pilihanJawaban),
        );
      case 'PBK':
        List<String>? jawabanSiswaSebelumnya, kunciJawaban;
        List<dynamic>? jawabanSiswa = _tobProvider.soal.jawabanSiswa;
        List<dynamic>? kunci = _tobProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }
        if (kunci != null && kunci.isNotEmpty) {
          kunciJawaban = kunci.cast<String>();
        }

        return PilihanBergandaKompleks(
          jsonOpsiJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          kunciJawaban: kunciJawaban,
          isBolehLihatKunci: isBolehLihatSolusi,
          onClickPilihJawaban: (widget.isBolehLihatSolusi)
              ? null
              : (listPilihanJawaban) async =>
                  await _setTempJawaban(listPilihanJawaban),
        );
      case 'PBCT':
        List<String>? jawabanSiswaSebelumnya, kunciJawaban;
        List<dynamic>? jawabanSiswa = _tobProvider.soal.jawabanSiswa;
        List<dynamic>? kunci = _tobProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }
        if (kunci != null && kunci.isNotEmpty) {
          kunciJawaban = kunci.cast<String>();
        }

        return PilihanBergandaComplexTerbatas(
          jsonOpsiJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          kunciJawaban: kunciJawaban,
          isBolehLihatKunci: isBolehLihatSolusi,
          onClickPilihJawaban: (widget.isBolehLihatSolusi)
              ? null
              : (listPilihanJawaban) async =>
                  await _setTempJawaban(listPilihanJawaban),
        );
      case 'PBM':
        List<int>? jawabanSiswaSebelumnya;
        List<dynamic>? jawabanSiswa = _tobProvider.soal.jawabanSiswa;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<int>();
        }

        return PilihanBergandaMemasangkan(
          jsonPernyataanOpsi: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          onSimpanJawaban: (widget.isBolehLihatSolusi)
              ? null
              : (listJawaban) async => await _setTempJawaban(listJawaban),
        );
      case 'PBT':
        List<int>? jawabanSiswaSebelumnya;
        List<int> kunciJawabanCast = [];
        List? jawabanSiswa = _tobProvider.soal.jawabanSiswa;
        List? kunciJawaban = _tobProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<int>();
        }
        if (kunciJawaban != null && kunciJawaban.isNotEmpty) {
          kunciJawabanCast = kunciJawaban.cast<int>();
        }

        return PilihanBergandaTabel(
          jsonTabelJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          bolehLihatSolusi: widget.isBolehLihatSolusi,
          kunciJawaban: kunciJawabanCast,
          onSelectJawaban: (widget.isBolehLihatSolusi)
              ? null
              : (listJawaban) async => await _setTempJawaban(listJawaban),
        );
      case 'PBB':
        Map<String, dynamic>? jawabanSiswaSebelumnya =
            (_tobProvider.soal.jawabanSiswa != null)
                ? Map<String, dynamic>.from(_tobProvider.soal.jawabanSiswa)
                : null;

        return PilihanBergandaBercabang(
          jsonOpsiJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          onSimpanJawaban: (widget.isBolehLihatSolusi)
              ? null
              : (jawabanAlasan) async => await _setTempJawaban(jawabanAlasan),
        );
      case 'ESSAY':
        return JawabanEssay(
          jawabanSebelumnya: _tobProvider.soal.jawabanSiswa,
          onSimpanJawaban: (widget.isBolehLihatSolusi)
              ? null
              : (isiJawaban) async => await _setTempJawaban(isiJawaban),
        );
      case 'ESSAY MAJEMUK':
        List<String>? jawabanSiswaSebelumnya;
        List<dynamic>? jawabanSiswa = _tobProvider.soal.jawabanSiswa;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }

        return JawabanEssayMajemuk(
          jsonSoalJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          onSimpanJawaban: (widget.isBolehLihatSolusi)
              ? null
              : (isiJawaban) async => await _setTempJawaban(isiJawaban),
        );
      default:
        return PilihanBergandaSederhana(
          jsonOpsiJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: _tobProvider.soal.jawabanSiswa,
          kunciJawaban: _tobProvider.soal.kunciJawaban,
          isBolehLihatKunci: isBolehLihatSolusi,
          onClickPilihJawaban: (widget.isBolehLihatSolusi)
              ? null
              : (pilihanJawaban) async => _setTempJawaban(pilihanJawaban),
        );
    }
  }

  Future<bool> _bottomDialog(
      {String title = 'Perhatian!!',
      String message =
          'Kumpulkan jawaban kamu jika ingin keluar dari halaman ini. '
              'Pengumpulan hanya dapat dilakukan satu kali saja. '
              'Soal yang belum dijawab akan dianggap kosong',
      List<Widget> Function(FlashController controller)? actions}) async {
    if (gPreviousBottomDialog?.isDisposed == false) {
      gPreviousBottomDialog?.dismiss(false);
    }
    gPreviousBottomDialog = DefaultFlashController<bool>(
      context,
      persistent: true,
      barrierColor: Colors.black54,
      barrierBlur: 2,
      barrierDismissible: true,
      onBarrierTap: () => Future.value(false),
      barrierCurve: Curves.easeInOutCubic,
      transitionDuration: const Duration(milliseconds: 300),
      builder: (context, controller) {
        return FlashBar(
          useSafeArea: true,
          controller: controller,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          clipBehavior: Clip.hardEdge,
          margin: (context.isMobile)
              ? const EdgeInsets.all(14)
              : EdgeInsets.symmetric(
                  horizontal: context.dw * .2,
                ),
          backgroundColor: context.background,
          title: Text(title),
          content: Text(message),
          titleTextStyle: context.text.titleMedium,
          contentTextStyle: context.text.bodySmall,
          indicatorColor: context.secondaryColor,
          icon: const Icon(Icons.info_outline),
          actions: (actions != null)
              ? actions(controller)
              : [
                  TextButton(
                      onPressed: () => controller.dismiss(false),
                      style: TextButton.styleFrom(
                          foregroundColor: context.onBackground),
                      child: const Text('Mengerti'))
                ],
        );
      },
    );

    bool? result = await gPreviousBottomDialog?.show();

    return result ?? false;
  }
}
