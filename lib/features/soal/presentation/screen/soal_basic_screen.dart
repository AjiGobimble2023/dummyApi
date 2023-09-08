import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/shared/widget/html/custom_html_widget.dart';
import '../widget/solusi_widget.dart';
import '../widget/sobat_tips_widget.dart';
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
import '../../module/bundel_soal/entity/bundel_soal.dart';
import '../../module/paket_soal/presentation/provider/paket_soal_provider.dart';
import '../../module/bundel_soal/presentation/provider/bundel_soal_provider.dart';
import '../../../video/presentation/widget/video_player_card.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../bookmark/presentation/provider/bookmark_provider.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/util/platform_channel.dart';
import '../../../../core/shared/provider/log_provider.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/screen/custom_will_pop_scope.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/widget/html/widget_from_html.dart';
import '../../../../core/shared/widget/watermark/watermark_widget.dart';

class SoalBasicScreen extends StatefulWidget {
  final OpsiUrut? opsiUrutBundel;
  final String? idBundel;
  final String? namaKelompokUjian;
  final String? kodeBab;
  final String? namaBab;
  final String kodeTOB;
  final String kodePaket;
  final String namaJenisProduk;
  final int idJenisProduk;
  final int mulaiDariSoalNomor;
  final DateTime? tanggalKedaluwarsa;
  final String diBukaDariRoute;
  final bool isPaket;
  final bool isSimpan;
  final bool isBisaBookmark;

  const SoalBasicScreen(
      {Key? key,
      this.opsiUrutBundel,
      this.idBundel,
      this.namaKelompokUjian,
      this.kodeBab,
      this.namaBab,
      required this.kodeTOB,
      required this.kodePaket,
      required this.namaJenisProduk,
      required this.idJenisProduk,
      this.mulaiDariSoalNomor = 1,
      this.tanggalKedaluwarsa,
      required this.diBukaDariRoute,
      this.isSimpan = true,
      required this.isPaket,
      this.isBisaBookmark = true})
      : super(key: key);

  @override
  State<SoalBasicScreen> createState() => _SoalBasicScreenState();
}

class _SoalBasicScreenState extends State<SoalBasicScreen> {
  final _scrollController = ScrollController();
  final _nomorSoalScrollController = ScrollController();
  late final NavigatorState _navigator = Navigator.of(context);
  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();
  late final BookmarkProvider _bookmarkProvider =
      context.read<BookmarkProvider>();
  late final BundelSoalProvider _bundelSoalProvider =
      context.watch<BundelSoalProvider>();
  late final PaketSoalProvider _paketSoalProvider =
      context.watch<PaketSoalProvider>();

  // int _jumlahFlashBottomTerbuka = 0;
  // DefaultFlashController? gPreviousBottomDialog;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1300)).then((value) =>
        PlatformChannel.setSecureScreen(Constant.kRouteSoalBasicScreen));

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
    Future.delayed(gDelayedNavigation).then(
      (_) => gNavigatorKey.currentContext!
          .read<BookmarkProvider>()
          .bookmarkUpdated = false,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlatformChannel.setSecureScreen(Constant.kRouteSoalBasicScreen);
    return CustomWillPopScope(
      swipeSensitivity:
          (!widget.isSimpan && !_isSudahDikumpulkanSemua()) ? 20 : 12,
      onWillPop: () async {
        if (_isLoading()) {
          return Future<bool>.value(true);
        }
        if (widget.namaJenisProduk == 'e-Empati Wajib' &&
            !_isSudahDikumpulkanSemua()) {
          return await _kumpulkanJawabanEmpatiWajib();
        }
        if (!widget.isSimpan &&
            widget.namaJenisProduk != 'e-Empati Wajib' &&
            !_isSudahDikumpulkanSemua()) {
          await _bottomDialog(
              title: 'Hi Sobat',
              message:
                  'Jika ingin keluar dari halaman pengerjaan, silahkan kumpulkan jawaban kamu ya.');

          return Future.value(false);
        }
        _saveLog();
        return Future.value(widget.isSimpan || _isSudahDikumpulkanSemua());
      },
      onDragRight: () async {
        if (widget.isSimpan || _isSudahDikumpulkanSemua() || _isLoading()) {
          logger.log('POP NAVIGATION >> ${_isSudahDikumpulkanSemua()}');
          _saveLog();
          _navigator.pop();
        } else if (widget.namaJenisProduk == 'e-Empati Wajib') {
          bool isSubmitJawaban = await _kumpulkanJawabanEmpatiWajib();

          logger.log('SUBMIT JAWABAN: $isSubmitJawaban');
          if (isSubmitJawaban) {
            _saveLog();
            // final duration = Duration(
            //     seconds: 2, milliseconds: gDelayedNavigation.inMilliseconds);
            await Future.delayed(gDelayedNavigation).then(
              (_) => _navigator
                  .popUntil(ModalRoute.withName(widget.diBukaDariRoute)),
            );
          }
        } else if (widget.namaJenisProduk != 'e-Empati Wajib' &&
            !_isSudahDikumpulkanSemua()) {
          await _bottomDialog(
              title: 'Hi Sobat',
              message:
                  'Jika ingin keluar dari halaman pengerjaan, silahkan kumpulkan jawaban kamu ya.');
        }
      },
      child: Scaffold(
        backgroundColor: context.primaryColor,
        appBar: (context.isMobile) ? _buildAppBar() : null,
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
          tablet: _buildTabletView(context),
        ),
        floatingActionButton: (!context.isMobile)
            ? null
            : (!_isLoading() && !widget.kodePaket.contains('VAK'))
                ? _buildSobatTipsButton()
                : null,
        bottomNavigationBar: (context.isMobile) ? _buildBottomNavBar() : null,
      ),
    );
  }

  ListView _buildListViewBody(BuildContext context) {
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: min(20, context.dp(14)),
        left: min(24, context.dp(16)),
        right: min(24, context.dp(16)),
        bottom: context.dp(18),
      ),
      children: (_isLoading())
          ? _buildLoadingWidget(context)
          : [
              _buildWacanaWidget(),
              _buildSoalWidget(),
              _buildJawabanWidget(),
              if (!_isSudahDikumpulkan()) SizedBox(height: context.dp(40)),
              if (_isSudahDikumpulkan() &&
                  _checkKedaluwarsa() &&
                  widget.namaJenisProduk != 'e-VAK')
                SolusiWidget(
                  accessFrom: AccessVideoCardFrom.videoSolusi,
                  idSoal: (widget.isPaket)
                      ? _paketSoalProvider.soal.idSoal
                      : _bundelSoalProvider.soal.idSoal,
                  tipeSoal: (widget.isPaket)
                      ? _paketSoalProvider.soal.tipeSoal
                      : _bundelSoalProvider.soal.tipeSoal,
                  kunciJawaban: (widget.isPaket)
                      ? _paketSoalProvider.soal.kunciJawaban
                      : _bundelSoalProvider.soal.kunciJawaban,
                  idVideo: (widget.isPaket)
                      ? _paketSoalProvider.soal.idVideo
                      : _bundelSoalProvider.soal.idVideo,
                )
            ],
    );
  }

  void _saveLog() {
    if (!_authOtpProvider.isLogin || _authOtpProvider.isOrtu) {
      return;
    } else {
      String? jenisProduk;
      switch (widget.idJenisProduk) {
        case 65:
          jenisProduk = 'VAK';
          break;
        case 71:
          jenisProduk = 'Empati Mandiri';
          break;
        case 72:
          jenisProduk = 'Empati Wajib';
          break;
        case 76:
          jenisProduk = 'Latihan Extra';
          break;
        case 77:
          jenisProduk = 'Paket Intensif';
          break;
        case 78:
          jenisProduk = 'Paket Soal Koding';
          break;
        case 79:
          jenisProduk = 'Pendalaman Materi';
          break;
        case 82:
          jenisProduk = 'Soal Referensi';
          break;
        default:
          break;
      }
      gNavigatorKey.currentContext!.read<LogProvider>().saveLog(
            userId: gNoRegistrasi,
            userType: "SISWA",
            menu: jenisProduk,
            accessType: 'Keluar',
            info:
                "${(widget.namaKelompokUjian != null) ? widget.namaKelompokUjian : ''}"
                "${(widget.namaKelompokUjian != null) ? ', ' : ''}${widget.kodePaket}"
                "${(widget.namaBab != null) ? ', ' : ''}"
                "${(widget.namaBab != null) ? widget.namaBab : ''}",
          );
      gNavigatorKey.currentContext!
          .read<LogProvider>()
          .sendLogActivity("SISWA");
      // Navigator.pop(context);
    }
  }

  /// This function is triggered when the user presses the back-to-top button
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool _isLoading() => (widget.isPaket && !_paketSoalProvider.isSoalExist)
      ? true
      : (widget.isPaket)
          ? _paketSoalProvider.isLoadingSoal
          : (_bundelSoalProvider.isSoalExist)
              ? _bundelSoalProvider.isLoadingSoal
              : true;

  bool _isBookmarked() => (_isLoading())
      ? false
      : (widget.isPaket)
          ? _paketSoalProvider.soal.isBookmarked
          : _bundelSoalProvider.soal.isBookmarked;

  bool _isSudahDikumpulkan() => (_isLoading())
      ? false
      : (widget.isPaket)
          ? _paketSoalProvider.soal.sudahDikumpulkan
          : _bundelSoalProvider.soal.sudahDikumpulkan;

  bool _isSudahDikumpulkanSemua() => (_isLoading())
      ? false
      : (widget.isPaket)
          ? _paketSoalProvider.isSudahDikumpulkanSemua(
              kodePaket: widget.kodePaket,
            )
          : _bundelSoalProvider.isSudahDikumpulkanSemua;

  bool _checkKedaluwarsa() {
    if (_isLoading()) return false;
    // Jika bukan paket, akan di anggap sudah kedaluwarsa
    // untuk menampilkan solusi soal.
    // if (!widget.isPaket) return true;
    // Jika paket soal sudah melewati tanggal berlaku,
    // baru siswa dapat melihat solusi-nya.
    // return _paketSoalProvider.serverTime.isAfter(widget.tanggalKedaluwarsa!);
    // Perbaikan 10 Agustus 2023
    // Keputusan rapat memunculkan solusi langsung setelah siswa menyimpan jawaban
    // baik itu EMWA maupun EMMA.
    return true;
  }

  List<Widget> _buildLoadingWidget(BuildContext context) => [
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

  /// NOTE: kumpulan function
  /// [_simpanJawaban] merupakan fungsi untuk menyimpan jawaban siswa.
  /// Soal hanya akan disimpan yang sudah dikerjakan saja, siswa dapat kembali
  /// melanjutkan mengerjakan sisanya nanti.
  Future<bool> _simpanJawaban() async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    if (widget.isPaket) {
      await _paketSoalProvider.kumpulkanJawabanSiswa(
        isKumpulkan: false,
        tahunAjaran: _authOtpProvider.tahunAjaran,
        idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
            _authOtpProvider.idSekolahKelas.value ??
            '14',
        noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
        tipeUser: _authOtpProvider.userData?.siapa,
        idKota: _authOtpProvider.userData?.idKota,
        idGedung: _authOtpProvider.userData?.idGedung,
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: widget.kodeTOB,
        kodePaket: widget.kodePaket,
      );
    } else {
      await _bundelSoalProvider.simpanJawabanSiswa(
        tahunAjaran: _authOtpProvider.tahunAjaran,
        idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
            _authOtpProvider.idSekolahKelas.value ??
            '14',
        noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
        tipeUser: _authOtpProvider.userData?.siapa,
        idKota: _authOtpProvider.userData?.idKota,
        idGedung: _authOtpProvider.userData?.idGedung,
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: widget.kodeTOB,
        kodePaket: widget.kodePaket,
      );
    }

    // Setelah save jawaban, lalu kirim save Bookmark
    if (_authOtpProvider.isLogin && widget.isBisaBookmark) {
      await _bookmarkProvider.updateBookmark(
          isSiswa: _authOtpProvider.isSiswa,
          noRegistrasi: _authOtpProvider.userData!.noRegistrasi);
    }
    completer.complete();
    return true;
  }

  /// [_kumpulkanJawaban] merupakan fungsi untuk mengumpulkan semua jawaban siswa,
  /// jika soal belum dikerjakan, maka akan dianggap kosong.
  Future<bool> _kumpulkanJawaban() async {
    bool kumpulkanConfirmed =
        (widget.namaJenisProduk != 'e-Empati Wajib') ? false : true;
    if (widget.namaJenisProduk != 'e-Empati Wajib') {
      kumpulkanConfirmed = await _bottomDialog(
          title: 'Apakah sobat sudah selesai mengerjakan soal?',
          message:
              'Kumpulkan jawaban berarti seluruh jawaban akan dikumpulkan, '
              'soal-soal yang belum dikerjakan akan dianggap kosong. Kumpulkan sekarang?',
          actions: (controller) => [
                TextButton(
                    onPressed: () => controller.dismiss(false),
                    style: TextButton.styleFrom(
                        foregroundColor: context.onBackground),
                    child: const Text('Nanti Saja')),
                ElevatedButton(
                    onPressed: () => controller.dismiss(true),
                    child: const Text('Kumpulkan')),
              ]);
    }

    if (kumpulkanConfirmed) {
      var completer = Completer();
      // ignore: use_build_context_synchronously
      context.showBlockDialog(dismissCompleter: completer);

      if (widget.isPaket) {
        await _paketSoalProvider.kumpulkanJawabanSiswa(
          isKumpulkan: true,
          tahunAjaran: _authOtpProvider.tahunAjaran,
          idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
              _authOtpProvider.idSekolahKelas.value ??
              '14',
          noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
          tipeUser: _authOtpProvider.userData?.siapa,
          idKota: _authOtpProvider.userData?.idKota,
          idGedung: _authOtpProvider.userData?.idGedung,
          idJenisProduk: widget.idJenisProduk,
          namaJenisProduk: widget.namaJenisProduk,
          kodeTOB: widget.kodeTOB,
          kodePaket: widget.kodePaket,
        );
      }

      // Setelah save jawaban, lalu kirim save Bookmark
      if (_authOtpProvider.isLogin && widget.isBisaBookmark) {
        await _bookmarkProvider.updateBookmark(
            isSiswa: _authOtpProvider.isSiswa,
            noRegistrasi: _authOtpProvider.userData!.noRegistrasi);
      }
      completer.complete();
      if (widget.namaJenisProduk != 'e-Empati Wajib') {
        // final duration = Duration(
        //     seconds: 2, milliseconds: gDelayedNavigation.inMilliseconds);
        Future.delayed(gDelayedNavigation).then(
          (_) => _navigator.popUntil(
            ModalRoute.withName(widget.diBukaDariRoute),
          ),
        );
      }
    }
    return kumpulkanConfirmed;
  }

  /// [_kumpulkanJawabanEmpatiWajib] merupakan fungsi untuk mengumpulkan semua
  /// jawaban siswa dari soal empati wajib, akan muncul bottom dialog untuk memilih
  /// apakah akan menyimpan soal (mengumpulkan hanya yang sudah dikerjakan)
  /// atau mengumpulkan secara menyeluruh.
  Future<bool> _kumpulkanJawabanEmpatiWajib() async {
    if (!widget.isPaket) return true;

    bool result = await _bottomDialog(
        title: 'Apakah sobat sudah selesai mengerjakan soal?',
        message:
            '>> Pilih kumpulkan jika Sobat mau mengumpulkan seluruh soal!\n'
            '>> Pilih simpan jika Sobat hanya ingin kumpulkan yang sudah dikerjakan saja!',
        actions: (controller) => [
              TextButton(
                  onPressed: () async {
                    bool selesai = await _kumpulkanJawaban();
                    controller.dismiss(selesai);
                  },
                  child: const Text('Kumpulkan')),
              ElevatedButton(
                  onPressed: () async {
                    bool selesai = await _simpanJawaban();
                    controller.dismiss(selesai);
                  },
                  child: const Text('Simpan')),
            ]);

    logger.log('DIALOG RESULT: $result');
    return result;
  }

  Future<void> _bookmarkToggle() async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    if (widget.isPaket) {
      await _paketSoalProvider.toggleBookmark(
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: widget.kodeTOB,
        kodePaket: widget.kodePaket,
        idBundel: widget.idBundel,
        kodeBab: widget.kodeBab,
        namaBab: widget.namaBab,
        tanggalKedaluwarsa: (widget.tanggalKedaluwarsa != null)
            ? DataFormatter.dateTimeToString(widget.tanggalKedaluwarsa!)
            : null,
        isPaket: widget.isPaket,
        isSimpan: widget.isSimpan,
      );
    } else {
      await _bundelSoalProvider.toggleBookmark(
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: widget.kodeTOB,
        kodePaket: widget.kodePaket,
        idBundel: widget.idBundel,
        kodeBab: widget.kodeBab,
        namaBab: widget.namaBab,
        tanggalKedaluwarsa: (widget.tanggalKedaluwarsa != null)
            ? DataFormatter.dateTimeToString(widget.tanggalKedaluwarsa!)
            : null,
        isPaket: widget.isPaket,
        isSimpan: widget.isSimpan,
      );
    }
    await _bookmarkProvider.reloadBookmarkFromHive();
    completer.complete();
  }

  Future<void> _raguRaguToggle(bool? isRagu) async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    if (widget.isPaket) {
      await _paketSoalProvider.toggleRaguRagu(
        tahunAjaran: _authOtpProvider.tahunAjaran,
        idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
            _authOtpProvider.idSekolahKelas.value ??
            '14',
        noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
        tipeUser: _authOtpProvider.userData?.siapa,
        kodePaket: widget.kodePaket,
      );
      completer.complete();
    } else {
      await _bundelSoalProvider.toggleRaguRagu(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(min(32, context.dp(24))),
        ),
      ),
      builder: (context) {
        childWidget ??= SobatTipsWidget(
          isBeliTeori: isBeliLengkap || isBeliSingkat || isBeliRingkas,
          getSobatTips: (widget.isPaket)
              ? _paketSoalProvider.getSobatTips(
                  idSoal: idSoal,
                  idBundel: idBundel,
                  isBeliLengkap: isBeliLengkap,
                  isBeliSingkat: isBeliSingkat,
                  isBeliRingkas: isBeliRingkas,
                )
              : _bundelSoalProvider.getSobatTips(
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
    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      if (widget.isPaket) {
        context.read<PaketSoalProvider>().getDaftarSoal(
              isRefresh: isRefresh,
              isKedaluwarsa: (widget.tanggalKedaluwarsa != null)
                  ? DateTime.now()
                      .serverTimeFromOffset
                      .isAfter(widget.tanggalKedaluwarsa!)
                  : false,
              jenisProduk: widget.namaJenisProduk,
              isKumpulkan: !widget.isSimpan,
              nomorSoalAwal: widget.mulaiDariSoalNomor,
              kodePaket: widget.kodePaket,
              tahunAjaran: _authOtpProvider.tahunAjaran,
              idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
                  _authOtpProvider.idSekolahKelas.value ??
                  '14',
              noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
              tipeUser: _authOtpProvider.userData?.siapa,
            );
      } else {
        context.read<BundelSoalProvider>().getDaftarSoal(
              isRefresh: isRefresh,
              tahunAjaran: _authOtpProvider.tahunAjaran,
              idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
                  _authOtpProvider.idSekolahKelas.value ??
                  '14',
              noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
              tipeUser: _authOtpProvider.userData?.siapa,
              kodePaket: widget.kodePaket,
              opsiUrut: (widget.kodeBab == null)
                  ? OpsiUrut.nomor
                  : widget.opsiUrutBundel ?? OpsiUrut.bab,
              jenisProduk: widget.namaJenisProduk,
              nomorSoalAwal: widget.mulaiDariSoalNomor,
              kodeBab: widget.kodeBab,
              idBundel: widget.idBundel!,
            );
      }
    });
  }

  Future<void> _setTempJawaban(dynamic jawabanSiswa) async {
    if (widget.isPaket) {
      await _paketSoalProvider.setTempJawaban(
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
    } else {
      await _bundelSoalProvider.setTempJawaban(
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

  Row _buildTabletView(BuildContext context) {
    return Row(
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
                  Transform.translate(
                    offset: const Offset(-14, 0),
                    child: Row(
                      children: [
                        _buildBookmarkButton(),
                        Expanded(child: _buildAppBarTitle()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildTingkatKesulitanSoal((_isLoading())
                          ? 0
                          : (widget.isPaket)
                              ? _paketSoalProvider.soal.tingkatKesulitan
                              : _bundelSoalProvider.soal.tingkatKesulitan),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: _buildSubmitButton(),
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
                      if (!_isLoading() && !widget.kodePaket.contains('VAK'))
                        _buildSobatTipsButton(),
                      if (!_isLoading()) const SizedBox(height: 14),
                      _buildBottomNavBar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        child: Wrap(
          spacing: min(18, context.dp(16)),
          runSpacing: min(18, context.dp(16)),
          children: List.generate(
            (widget.isPaket)
                ? _paketSoalProvider.jumlahSoal
                : _bundelSoalProvider.jumlahSoal,
            (index) {
              Color warnaNomor = context.onBackground;
              Color warnaNomorContainer = context.background;
              Color warnaBorder = context.onBackground;
              int nomorSoal = (widget.isPaket)
                  ? _paketSoalProvider.getSoalByIndex(index).nomorSoalSiswa
                  : _bundelSoalProvider.getSoalByIndex(index).nomorSoalSiswa;
              int indexNomorSoal = (widget.isPaket)
                  ? _paketSoalProvider.indexSoal
                  : _bundelSoalProvider.indexSoal;

              // Bool value
              bool isRagu = (widget.isPaket)
                  ? _paketSoalProvider.getSoalByIndex(index).isRagu
                  : _bundelSoalProvider.getSoalByIndex(index).isRagu;
              bool isSudahDikumpulkan = (widget.isPaket)
                  ? _paketSoalProvider.getSoalByIndex(index).sudahDikumpulkan
                  : _bundelSoalProvider.getSoalByIndex(index).sudahDikumpulkan;

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
              return InkWell(
                onTap: () {
                  (widget.isPaket)
                      ? _paketSoalProvider.jumpToSoalNomor(index)
                      : _bundelSoalProvider.jumpToSoalNomor(index);

                  if (context.isMobile) {
                    Navigator.pop(context);
                  }

                  _scrollToTop();
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
    );
  }

  /// NOTE: kumpulan Widget

  Widget _buildBookmarkButton() => widget.isBisaBookmark
      ? IconButton(
          onPressed: (_isLoading()) ? null : _bookmarkToggle,
          icon: Icon(
            (!_isLoading() && _isBookmarked())
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: context.onPrimary,
          ),
        )
      : SizedBox(width: min(16, context.dp(14)));

  AppBar _buildAppBar() => AppBar(
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leadingWidth: widget.isBisaBookmark ? null : context.dp(14),
        leading: _buildBookmarkButton(),
        title: _buildAppBarTitle(),
        bottom: _buildBintangDanNomorSoal(),
        actions: [
          Padding(
              padding: EdgeInsets.only(
                top: context.dp(12),
                left: context.dp(12),
                right: context.dp(14),
              ),
              child: _buildSubmitButton()),
        ],
      );

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: (_isLoading() || _isSudahDikumpulkan())
          ? null
          : (widget.namaJenisProduk == 'e-Empati Wajib')
              ? () async {
                  bool isSubmitJawaban = await _kumpulkanJawabanEmpatiWajib();

                  logger.log('IS SUBMIT JAWABAN: $isSubmitJawaban');
                  if (isSubmitJawaban) {
                    // final duration = Duration(
                    //     seconds: 2,
                    //     milliseconds: gDelayedNavigation.inMilliseconds);
                    await Future.delayed(gDelayedNavigation).then(
                      (_) => _navigator.popUntil(
                          ModalRoute.withName(widget.diBukaDariRoute)),
                    );
                  }
                }
              : widget.isSimpan
                  ? () async => await _simpanJawaban()
                  : () async => await _kumpulkanJawaban(),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.secondaryColor,
        foregroundColor: context.onSecondary,
        minimumSize:
            (context.isMobile) ? Size(context.dp(90), context.dp(64)) : null,
        padding: (context.isMobile)
            ? null
            : const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        textStyle: context.text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.dp(8)),
        ),
      ),
      child: Text(widget.isSimpan ? 'Simpan' : 'Kumpulkan',
          textAlign: TextAlign.center),
    );
  }

  Column _buildAppBarTitle() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          (_isLoading())
              ? ShimmerWidget(
                  width: min(82, context.dp(65)),
                  height: min(32, context.dp(20)))
              : Text(
                  (widget.isPaket ||
                          (widget.opsiUrutBundel == OpsiUrut.nomor ||
                              widget.kodeBab == null))
                      ? widget.kodePaket
                      : widget.namaKelompokUjian!,
                  style: context.text.labelLarge?.copyWith(
                    color: context.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          (_isLoading())
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ShimmerWidget(
                      width: min(140, context.dp(100)),
                      height: min(20, context.dp(14))),
                )
              : Text(
                  widget.isPaket
                      ? _paketSoalProvider.soal.namaKelompokUjian
                      : (widget.opsiUrutBundel == OpsiUrut.nomor ||
                              widget.namaBab == null)
                          ? _bundelSoalProvider.soal.namaKelompokUjian
                          : 'Bab ${widget.namaBab}',
                  style: context.text.labelSmall
                      ?.copyWith(color: context.onPrimary))
        ],
      );

  PreferredSize _buildBintangDanNomorSoal() => PreferredSize(
        preferredSize: Size(context.dw, context.dp(36)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dp(14)),
          child: Row(
            children: [
              ..._buildTingkatKesulitanSoal((_isLoading())
                  ? 0
                  : (widget.isPaket)
                      ? _paketSoalProvider.soal.tingkatKesulitan
                      : _bundelSoalProvider.soal.tingkatKesulitan),
              const Spacer(),
              TextButton.icon(
                onPressed: _onClickNomorSoal,
                icon: const Icon(Icons.arrow_drop_down_sharp),
                label: (_isLoading())
                    ? ShimmerWidget.rounded(
                        width: context.dp(84),
                        height: context.dp(24),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : Text(
                        'No ${(widget.isPaket) ? _paketSoalProvider.soal.nomorSoalSiswa : _bundelSoalProvider.soal.nomorSoalSiswa}'
                        '/${(widget.isPaket) ? _paketSoalProvider.jumlahSoal : _bundelSoalProvider.jumlahSoal}'),
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

  List<Widget> _buildTingkatKesulitanSoal(int tingkatKesulitan) =>
      List.generate(
        5,
        (index) => Icon(
          index < tingkatKesulitan
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          size: (context.isMobile) ? 28 : 32,
          color: context.onPrimary,
        ),
      );

  Widget _buildWacanaWidget() {
    bool wacanaExist = (widget.isPaket)
        ? _paketSoalProvider.soal.wacana != null
        : _bundelSoalProvider.soal.wacana != null;

    String? wacana = (!wacanaExist)
        ? null
        : (widget.isPaket)
            ? _paketSoalProvider.soal.wacana!.wacanaText
            : _bundelSoalProvider.soal.wacana!.wacanaText;

    return (!wacanaExist || wacana == null)
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dp(8)),
            child: (wacana.contains('table'))
                ? WidgetFromHtml(htmlString: wacana)
                : CustomHtml(htmlString: wacana),
          );
  }

  Widget _buildSoalWidget() {
    String textSoal = (widget.isPaket)
        ? _paketSoalProvider.soal.textSoal
        : _bundelSoalProvider.soal.textSoal;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dp(8)),
      child: (textSoal.contains('table'))
          ? WidgetFromHtml(htmlString: textSoal)
          : CustomHtml(htmlString: textSoal),
    );
  }

  ElevatedButton _buildSobatTipsButton() => ElevatedButton(
        onPressed: () => _onClickSobatTips(
          (widget.isPaket)
              ? _paketSoalProvider.soal.idSoal
              : _bundelSoalProvider.soal.idSoal,
          (widget.isPaket)
              ? _paketSoalProvider.soal.idBundle!
              : widget.idBundel!,
        ),
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

  Container _buildBottomNavBar() => Container(
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
            if (!_isSudahDikumpulkan())
              Checkbox(
                value: (_isLoading())
                    ? false
                    : (widget.isPaket)
                        ? _paketSoalProvider.soal.isRagu
                        : _bundelSoalProvider.soal.isRagu,
                onChanged: (_isLoading()) ? null : _raguRaguToggle,
                activeColor: context.secondaryColor,
                checkColor: context.onSecondary,
              ),
            if (!_isSudahDikumpulkan())
              Text(
                'Ragu',
                style: (context.isMobile)
                    ? context.text.labelLarge
                    : context.text.labelMedium,
              ),
            const Spacer(),
            (_isLoading())
                ? ShimmerWidget.rounded(
                    width: context.dp(24),
                    height: context.dp(24),
                    borderRadius: BorderRadius.circular(context.dp(8)),
                  )
                : IconButton(
                    onPressed: ((widget.isPaket)
                            ? _paketSoalProvider.isFirstSoal
                            : _bundelSoalProvider.isFirstSoal)
                        ? null
                        : () {
                            if (widget.isPaket) {
                              _paketSoalProvider.setPrevSoal();
                            } else {
                              _bundelSoalProvider.setPrevSoal();
                            }
                            _scrollToTop();
                          },
                    icon: const Icon(Icons.chevron_left_rounded)),
            if (_isLoading()) const SizedBox(width: 8),
            (_isLoading())
                ? ShimmerWidget.rounded(
                    width: context.dp(24),
                    height: context.dp(24),
                    borderRadius: BorderRadius.circular(context.dp(8)),
                  )
                : IconButton(
                    onPressed: ((widget.isPaket)
                            ? _paketSoalProvider.isLastSoal
                            : _bundelSoalProvider.isLastSoal)
                        ? null
                        : () {
                            if (widget.isPaket) {
                              _paketSoalProvider.setNextSoal();
                            } else {
                              _bundelSoalProvider.setNextSoal();
                            }
                            _scrollToTop();
                          },
                    icon: const Icon(Icons.chevron_right_rounded))
          ],
        ),
      );

  Widget _buildJawabanWidget() {
    if (kDebugMode) {
      logger.log('SOAL_BASIC_SCREEN-BuildJawabanWidget: '
          '${(widget.isPaket) ? _paketSoalProvider.soal.jawabanSiswa : _bundelSoalProvider.soal.jawabanSiswa}');
    }
    switch ((widget.isPaket)
        ? _paketSoalProvider.soal.tipeSoal
        : _bundelSoalProvider.soal.tipeSoal) {
      case 'PGB':
        return PilihanGandaBerbobot(
          jsonOpsiJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: (widget.isPaket)
              ? _paketSoalProvider.soal.jawabanSiswa
              : _bundelSoalProvider.soal.jawabanSiswa,
          kunciJawaban: (widget.isPaket)
              ? _paketSoalProvider.soal.kunciJawaban
              : _bundelSoalProvider.soal.kunciJawaban,
          isBolehLihatKunci:
              _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          onClickPilihJawaban: _isSudahDikumpulkan()
              ? null
              : (pilihanJawaban) async => await _setTempJawaban(pilihanJawaban),
        );
      case 'PBK':
        List<String>? jawabanSiswaSebelumnya, kunciJawaban;
        List<dynamic>? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;
        List<dynamic>? kunci = (widget.isPaket)
            ? _paketSoalProvider.soal.kunciJawaban
            : _bundelSoalProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }
        if (kunci != null && kunci.isNotEmpty) {
          kunciJawaban = kunci.cast<String>();
        }

        return PilihanBergandaKompleks(
          jsonOpsiJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          kunciJawaban: kunciJawaban,
          isBolehLihatKunci:
              _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          onClickPilihJawaban: _isSudahDikumpulkan()
              ? null
              : (listPilihanJawaban) async =>
                  await _setTempJawaban(listPilihanJawaban),
        );
      case 'PBCT':
        List<String>? jawabanSiswaSebelumnya, kunciJawaban;
        List<dynamic>? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;
        List<dynamic>? kunci = (widget.isPaket)
            ? _paketSoalProvider.soal.kunciJawaban
            : _bundelSoalProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }
        if (kunci != null && kunci.isNotEmpty) {
          kunciJawaban = kunci.cast<String>();
        }

        return PilihanBergandaComplexTerbatas(
          jsonOpsiJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          kunciJawaban: kunciJawaban,
          isBolehLihatKunci:
              _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          onClickPilihJawaban: _isSudahDikumpulkan()
              ? null
              : (listPilihanJawaban) async =>
                  await _setTempJawaban(listPilihanJawaban),
        );
      case 'PBM':
        List<int>? jawabanSiswaSebelumnya;
        List<dynamic>? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<int>();
        }

        return PilihanBergandaMemasangkan(
          jsonPernyataanOpsi: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          onSimpanJawaban: _isSudahDikumpulkan()
              ? null
              : (listJawaban) async => await _setTempJawaban(listJawaban),
        );
      case 'PBT':
        List<int>? jawabanSiswaSebelumnya;
        List<int> kunciJawabanCast = [];
        List<dynamic>? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;
        List? kunciJawaban = (widget.isPaket)
            ? _paketSoalProvider.soal.kunciJawaban
            : _bundelSoalProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<int>();
        }
        if (kunciJawaban != null && kunciJawaban.isNotEmpty) {
          kunciJawabanCast = kunciJawaban.cast<int>();
        }

        return PilihanBergandaTabel(
          jsonTabelJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          // Jika produk merupakan VAK tidak perlu bisa melihat solusi.
          bolehLihatSolusi: _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          kunciJawaban: kunciJawabanCast,
          onSelectJawaban: _isSudahDikumpulkan()
              ? null
              : (listJawaban) async => await _setTempJawaban(listJawaban),
        );
      case 'PBB':
        Map? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;

        return PilihanBergandaBercabang(
          jsonOpsiJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: (jawabanSiswa != null)
              ? Map<String, dynamic>.from(jawabanSiswa)
              : null,
          onSimpanJawaban: _isSudahDikumpulkan()
              ? null
              : (jawabanAlasan) async => await _setTempJawaban(jawabanAlasan),
        );
      case 'ESSAY':
        return JawabanEssay(
          jawabanSebelumnya: (widget.isPaket)
              ? _paketSoalProvider.soal.jawabanSiswa
              : _bundelSoalProvider.soal.jawabanSiswa,
          onSimpanJawaban: _isSudahDikumpulkan()
              ? null
              : (isiJawaban) async => await _setTempJawaban(isiJawaban),
        );
      case 'ESSAY MAJEMUK':
        List<String>? jawabanSiswaSebelumnya;
        List<dynamic>? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }

        return JawabanEssayMajemuk(
          jsonSoalJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          onSimpanJawaban: _isSudahDikumpulkan()
              ? null
              : (isiJawaban) async => await _setTempJawaban(isiJawaban),
        );
      default:
        return PilihanBergandaSederhana(
          jsonOpsiJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: (widget.isPaket)
              ? _paketSoalProvider.soal.jawabanSiswa
              : _bundelSoalProvider.soal.jawabanSiswa,
          kunciJawaban: (widget.isPaket)
              ? _paketSoalProvider.soal.kunciJawaban
              : _bundelSoalProvider.soal.kunciJawaban,
          isBolehLihatKunci:
              _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          onClickPilihJawaban: _isSudahDikumpulkan()
              ? null
              : (pilihanJawaban) async => _setTempJawaban(pilihanJawaban),
        );
    }
  }

  Future<bool> _bottomDialog(
      {String title = 'GO Kreasi',
      required String message,
      List<Widget> Function(FlashController controller)? actions}) async {
    if (gPreviousBottomDialog?.isDisposed == false) {
      gPreviousBottomDialog?.dismiss(false);
    }
    gPreviousBottomDialog = DefaultFlashController<bool>(
      context,
      persistent: true,
      barrierColor: Colors.black12,
      barrierBlur: 0,
      barrierDismissible: true,
      onBarrierTap: () => Future.value(false),
      barrierCurve: Curves.easeInOutCubic,
      transitionDuration: const Duration(milliseconds: 300),
      builder: (context, controller) {
        return DefaultTextStyle(
          style: TextStyle(color: context.onBackground),
          child: FlashBar(
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
          ),
        );
      },
    );

    bool? result = await gPreviousBottomDialog?.show();

    return result ?? false;
  }
}
