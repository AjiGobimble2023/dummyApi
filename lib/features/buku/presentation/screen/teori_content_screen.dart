import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/daftar_isi_content.dart';
import '../widget/teori_content_widget.dart';
import '../../entity/bab_buku.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/platform_channel.dart';
import '../../../../core/shared/provider/log_provider.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/widget/appbar/custom_app_bar.dart';
import '../../../../core/shared/widget/card/custom_card.dart';

class TeoriContentScreen extends StatefulWidget {
  final List<BabBuku> daftarIsi;
  final String? namaBabUtama;
  final String namaMataPelajaran;
  final String jenisBuku;
  final String kodeBab;
  final String levelTeori;
  final String kelengkapan;

  const TeoriContentScreen({
    super.key,
    required this.daftarIsi,
    this.namaBabUtama,
    required this.namaMataPelajaran,
    required this.jenisBuku,
    required this.kodeBab,
    required this.levelTeori,
    required this.kelengkapan,
  });

  @override
  State<TeoriContentScreen> createState() => _TeoriContentScreenState();
}

class _TeoriContentScreenState extends State<TeoriContentScreen> {
  final _animDuration = const Duration(milliseconds: 600);
  final _animCurves = Curves.easeInOutCubic;
  late final PageController _pageController =
      PageController(initialPage: _halamanAktif);

  late int _halamanAktif =
      widget.daftarIsi.indexWhere((bab) => bab.kodeBab == widget.kodeBab);

  late final String _titleAppBar = (widget.namaBabUtama != null)
      ? 'Bab ${widget.namaBabUtama}'
      : widget.namaMataPelajaran;

  late String _subTitleAppBar = '${_babAktif.kodeBab} ${_babAktif.namaBab}';
  late BabBuku _babAktif =
      widget.daftarIsi.firstWhere((bab) => bab.kodeBab == widget.kodeBab);

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1300)).then((value) =>
        PlatformChannel.setSecureScreen(Constant.kRouteBukuTeoriContent));
    super.initState();
  }

  @override
  void dispose() {
    PlatformChannel.setSecureScreen('POP', true);
    Future.delayed(gDelayedNavigation).then((_) {
      _saveLog();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlatformChannel.setSecureScreen(Constant.kRouteBukuTeoriContent);

    return Scaffold(
      backgroundColor: context.primaryColor,
      appBar: (context.isMobile) ? _buildAppBar(context) : null,
      floatingActionButton:
          (widget.daftarIsi.length > 1) ? _buildPageController(context) : null,
      body: ResponsiveBuilder(
        mobile: Container(
          width: context.dw,
          height: double.infinity,
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: (widget.daftarIsi.isEmpty)
              ? const Center(child: Text('Teori Bab Tidak Ada'))
              : (widget.daftarIsi.length < 2)
                  ? _buildTeoriContentWidget(0)
                  : _buildPageView(),
        ),
        tablet: Row(
          children: [
            Expanded(
              flex: (context.dw > 1100) ? 3 : 4,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          color: context.onPrimary,
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(child: _buildTitlePage(context)),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 18, bottom: 24, left: 20, right: 20),
                        decoration: BoxDecoration(
                          color: context.background,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(33),
                          child: _buildDaftarIsiContent(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                width: context.dw,
                height: double.infinity,
                decoration: BoxDecoration(color: context.background),
                child: (widget.daftarIsi.isEmpty)
                    ? const Center(child: Text('Teori Bab Tidak Ada'))
                    : (widget.daftarIsi.length < 2)
                        ? _buildTeoriContentWidget(0)
                        : _buildPageView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _saveLog() {
    if (gUser == null || gUser.isOrtu) {
      return;
    } else {
      gNavigatorKey.currentContext!.read<LogProvider>().saveLog(
            userId: gNoRegistrasi,
            userType: "SISWA",
            menu: "Buku Teori",
            accessType: 'Keluar',
            info: "${widget.namaMataPelajaran}, ${_babAktif.namaBab}",
          );
      gNavigatorKey.currentContext!
          .read<LogProvider>()
          .sendLogActivity("SISWA");
    }
  }

  Future<void> _onClickDaftarIsi() async {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    // BottomSheet Daftar Isi
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        childWidget ??= _buildDaftarIsiContent(context);
        return childWidget!;
      },
    );
  }

  DaftarIsiContent _buildDaftarIsiContent(BuildContext context) {
    return DaftarIsiContent(
      title: _titleAppBar,
      daftarBab: widget.daftarIsi,
      babAktif: _babAktif,
      onClickBabBuku: (selectedBab) {
        setState(() {
          _babAktif = selectedBab;
          _subTitleAppBar = '${selectedBab.kodeBab} ${selectedBab.namaBab}';
          _halamanAktif = widget.daftarIsi
              .indexWhere((bab) => bab.kodeBab == selectedBab.kodeBab);
          if (context.isMobile) {
            Navigator.pop(context);
          }
        });
        _pageController.animateToPage(_halamanAktif,
            duration: _animDuration, curve: _animCurves);
      },
    );
  }

  TeoriContentWidget _buildTeoriContentWidget(int index) => TeoriContentWidget(
        key: ValueKey('${widget.jenisBuku}-${widget.daftarIsi[index].kodeBab}'
            '-${widget.daftarIsi[index].idTeoriBab}'),
        kodeBab: widget.daftarIsi[index].kodeBab,
        namaBabSubBab: widget.daftarIsi[index].namaBab,
        idTeoriBab: widget.daftarIsi[index].idTeoriBab,
        namaMataPelajaran: widget.namaMataPelajaran,
        levelTeori: widget.levelTeori,
        kelengkapan: widget.kelengkapan,
        jenisBuku: widget.jenisBuku,
      );

  // Digunakan jika daftar isi ada lebih dari satu
  PageView _buildPageView() => PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (halaman) {
          setState(() {
            _halamanAktif = halaman;
            _babAktif = widget.daftarIsi[halaman];
            _subTitleAppBar = '${_babAktif.kodeBab} ${_babAktif.namaBab}';
          });
        },
        children: List<Widget>.generate(
          widget.daftarIsi.length,
          (index) => _buildTeoriContentWidget(index),
        ),
      );

  CustomCard _buildPageController(BuildContext context) => CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        elevation: 12,
        borderRadius: BorderRadius.circular(300),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: (_halamanAktif > 0)
                    ? () => _pageController.previousPage(
                        duration: _animDuration, curve: _animCurves)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded)),
            Text(
              '${_halamanAktif + 1} / ${widget.daftarIsi.length}',
              style: context.text.bodyMedium,
            ),
            IconButton(
              onPressed: (_halamanAktif == widget.daftarIsi.length - 1)
                  ? null
                  : () => _pageController.nextPage(
                      duration: _animDuration, curve: _animCurves),
              icon: const Icon(Icons.chevron_right),
            )
          ],
        ),
      );

  CustomAppBar _buildAppBar(BuildContext context) {
    return CustomAppBar(
      context,
      centerTitle: false,
      toolbarHeight: 72,
      jenisProduk: "Buku Teori",
      keterangan: "${widget.namaMataPelajaran}, ${_babAktif.namaBab}",
      backgroundColor: context.primaryColor,
      title: _buildTitlePage(context),
      actions: (widget.daftarIsi.isEmpty ||
              widget.daftarIsi.length == 1 ||
              !context.isMobile)
          ? null
          : [
              Padding(
                padding: EdgeInsets.all(min(20, context.dp(14))),
                child: ElevatedButton(
                  onPressed: _onClickDaftarIsi,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: context.onBackground,
                    backgroundColor: context.background,
                    surfaceTintColor: context.background,
                    textStyle: context.text.bodySmall,
                    padding: const EdgeInsets.only(
                      left: 12,
                      top: 8,
                      bottom: 8,
                      right: 8,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Daftar isi'),
                      SizedBox(width: 2),
                      Icon(Icons.expand_more_rounded)
                    ],
                  ),
                ),
              )
            ],
    );
  }

  Column _buildTitlePage(BuildContext context) {
    return Column(
      mainAxisSize: (context.isMobile) ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _titleAppBar,
          style: context.text.titleMedium?.copyWith(color: context.onPrimary),
          maxLines: (context.isMobile) ? 1 : 2,
          overflow:
              (context.isMobile) ? TextOverflow.fade : TextOverflow.ellipsis,
        ),
        Text(
          _subTitleAppBar,
          style: context.text.labelSmall?.copyWith(color: context.onPrimary),
          maxLines: (context.isMobile) ? 2 : 1,
          overflow:
              (context.isMobile) ? TextOverflow.fade : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
