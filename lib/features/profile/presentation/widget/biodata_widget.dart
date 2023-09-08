import 'dart:math';

import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'pilih_kelompok_ujian.dart';
import '../../entity/kelompok_ujian.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class BiodataWidget extends StatefulWidget {
  final String nomorHp;
  final String? email;
  final String? emailOrtu;
  final String? nomorHpOrtu;
  final String? kota;
  final String? sekolah;
  final String? nisn;
  final String? kampusImpian;
  final List<String>? daftarKelas;
  final void Function(RefreshController controller) onRefresh;

  const BiodataWidget(
      {Key? key,
      required this.nomorHp,
      this.email,
      this.emailOrtu,
      this.nomorHpOrtu,
      this.kota,
      this.nisn,
      this.sekolah,
      this.kampusImpian,
      this.daftarKelas,
      required this.onRefresh})
      : super(key: key);

  @override
  State<BiodataWidget> createState() => _BiodataWidgetState();
}

class _BiodataWidgetState extends State<BiodataWidget> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();

  @override
  void dispose() {
    HiveHelper.closeBox<KelompokUjian>(
        boxName: HiveHelper.kKelompokUjianPilihanBox);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaleFactor: context.textScale12),
      child: CustomSmartRefresher(
        isDark: true,
        controller: _refreshController,
        onRefresh: () async => widget.onRefresh(_refreshController),
        child: Container(
          width: (context.isMobile) ? context.dw : double.infinity,
          margin: EdgeInsets.only(
            top: min(14, context.dp(10)),
            right: min(24, context.dp(20)),
            left: min(24, context.dp(20)),
            bottom: min(36, context.dp(32)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: min(20, context.dp(16)),
            vertical: min(24, context.dp(20)),
          ),
          decoration: BoxDecoration(
            color: context.background,
            borderRadius:
                BorderRadius.circular((context.isMobile) ? 24 : context.dp(12)),
            boxShadow: const [
              BoxShadow(
                offset: Offset(1, 2),
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._buildSimpleItem(
                  context, 'Email', (widget.email ?? 'Email belum terdata')),
              ..._buildKelasWidget(context),
              ..._buildSimpleItem(context, 'Kota', (widget.kota ?? '-')),
              ..._buildSimpleItem(context, 'Nomor Handphone', widget.nomorHp),
              ..._buildSimpleItem(context, 'Asal Sekolah',
                  widget.sekolah ?? 'Asal sekolah belum terdata'),
              ..._buildSimpleItem(context, 'Email Ortu',
                  (widget.emailOrtu ?? 'Email orang tua belum terdata')),
              ..._buildSimpleItem(
                  context,
                  'Nomor Handphone Ortu',
                  widget.nomorHpOrtu ??
                      'Nomor handphone orang tua belum terdata'),
              if (_authOtpProvider.isSiswa) _buildPilihanMataUji(),
              Container(
                width: double.infinity,
                height: min(36, context.dp(32)),
                alignment: Alignment.bottomCenter,
                child: Text(
                  gKreasiVersion,
                  style: context.text.bodySmall,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openKelompokUjianBox() async {
    if (!HiveHelper.isBoxOpen<KelompokUjian>(
        boxName: HiveHelper.kKelompokUjianPilihanBox)) {
      await HiveHelper.openBox<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox);
    }
  }

  void _onClickPilihKelompokUjian() {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    showModalBottomSheet(
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
      builder: (_) {
        childWidget ??= const PilihKelompokUjian();
        return childWidget!;
      },
    );
  }

  List<Widget> _buildSimpleItem(
          BuildContext context, String title, String subTitle) =>
      [
        Text(title,
            style: context.text.labelMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subTitle, style: context.text.bodyMedium),
        const Divider()
      ];

  List<Widget> _buildKelasWidget(BuildContext context) => [
        Text('Kelas',
            style: context.text.labelMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        if (widget.daftarKelas == null ||
            (widget.daftarKelas?.isEmpty ?? false))
          Text('-', style: context.text.bodyMedium),
        if (widget.daftarKelas != null ||
            (widget.daftarKelas?.isNotEmpty ?? false))
          ...List<Widget>.generate(
              widget.daftarKelas!.length,
              (index) => Text('  ${index + 1}. ${widget.daftarKelas![index]}',
                  style: context.text.bodyMedium)),
        const Divider()
      ];

  Widget _buildKelompokUjianPilihanWidget(VoidCallback onClickPilihMataUji,
          List<KelompokUjian> kelompokUjianPilihan) =>
      InkWell(
        borderRadius: gDefaultShimmerBorderRadius,
        onTap: onClickPilihMataUji,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              maxLines: 1,
              overflow: TextOverflow.fade,
              textScaleFactor: context.textScale12,
              text: TextSpan(
                  text: 'Mata Uji Pilihan ',
                  style: context.text.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  children: [
                    if (kelompokUjianPilihan.isNotEmpty)
                      TextSpan(
                        text: '(Ubah Pilihan)',
                        style: context.text.labelSmall?.copyWith(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1),
                      )
                  ]),
            ),
            const SizedBox(height: 2),
            if (kelompokUjianPilihan.isEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text('Pilih mata uji pilihan kamu',
                        style: context.text.bodyMedium),
                  ),
                  const Icon(Icons.chevron_right_rounded)
                ],
              ),
            if (kelompokUjianPilihan.isNotEmpty)
              ...List<Widget>.generate(
                  kelompokUjianPilihan.length,
                  (index) => Text(
                      '  ${index + 1}. ${kelompokUjianPilihan[index].namaKelompokUjian}',
                      style: context.text.bodyMedium)),
            const Divider()
          ],
        ),
      );

  Widget _buildPilihanMataUji() => FutureBuilder<void>(
        future: _openKelompokUjianBox(),
        builder: (context, snapshot) =>
            (snapshot.connectionState == ConnectionState.waiting) ||
                    (!HiveHelper.isBoxOpen(
                        boxName: HiveHelper.kKelompokUjianPilihanBox))
                ? ShimmerWidget.rounded(
                    width: double.infinity,
                    height: context.dp(96),
                    borderRadius: gDefaultShimmerBorderRadius)
                : ValueListenableBuilder<Box<KelompokUjian>>(
                    valueListenable: HiveHelper.listenableKelompokUjian(),
                    builder: (context, box, _) {
                      List<KelompokUjian> listKelompokUjianPilihan =
                          box.values.toList();

                      return _buildKelompokUjianPilihanWidget(
                          _onClickPilihKelompokUjian, listKelompokUjianPilihan);
                    },
                  ),
      );
}
