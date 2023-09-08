import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/extensions.dart';
import '../../../../core/config/global.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../entity/kelompok_ujian.dart';
import '../provider/profile_provider.dart';

class PilihKelompokUjian extends StatefulWidget {
  final bool isFromTOBK;

  const PilihKelompokUjian({
    Key? key,
    this.isFromTOBK = false,
  }) : super(key: key);

  @override
  State<PilihKelompokUjian> createState() => _PilihKelompokUjianState();
}

class _PilihKelompokUjianState extends State<PilihKelompokUjian> {
  late final _getKelompokUjianPilihan = context
      .read<ProfileProvider>()
      .getKelompokUjianPilihan(
          noRegistrasi: context.read<AuthOtpProvider>().userData!.noRegistrasi);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Selector<AuthOtpProvider, String>(
        selector: (_, auth) => auth.tingkat,
        builder: (_, tingkatSekolah, __) => FutureBuilder<void>(
          future: _getKelompokUjianPilihan,
          builder: (context, snapshot) {
            bool isLoading =
                snapshot.connectionState == ConnectionState.waiting ||
                    context.select<ProfileProvider, bool>(
                        (profile) => profile.isLoadingPilihanKelompokUjian);

            if (isLoading) {
              return ShimmerWidget.rounded(
                  width: context.dw - 64,
                  height: min(114, context.dp(100)),
                  borderRadius: gDefaultShimmerBorderRadius);
            }

            return ValueListenableBuilder<Box<KelompokUjian>>(
                valueListenable: HiveHelper.listenableKelompokUjian(),
                builder: (context, box, _) {
                  ProfileProvider data = context.read<ProfileProvider>();
                  var opsiPilihan = data.getDaftarPilihanKelompokUjian(
                      tingkatSekolah: tingkatSekolah);
                  List<KelompokUjian> kelompokUjianPilihan =
                      box.values.toList();

                  return ListView(
                    // mainAxisSize: MainAxisSize.min,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    padding: EdgeInsets.only(
                      right: min(22, context.dp(18)),
                      left: min(22, context.dp(18)),
                      top: min(16, context.dp(12)),
                      bottom: min(24, context.dp(20)),
                    ),
                    shrinkWrap: true,
                    children: [
                      _buildDecoration(context),
                      const SizedBox(height: 12),
                      _buildHeader(context, opsiPilihan, tingkatSekolah),
                      const Divider(height: 20),
                      _buildOpsiPilihanKelompokUjian(
                          opsiPilihan, kelompokUjianPilihan),
                      if (opsiPilihan.isNotEmpty) const Divider(height: 20),
                      if (opsiPilihan.isNotEmpty)
                        Text(
                            ' *Minimal ${data.minimumPilihKelompokUjian} pilihan',
                            textScaleFactor: context.textScale11,
                            style: context.text.labelSmall
                                ?.copyWith(color: context.hintColor)),
                      if (opsiPilihan.isNotEmpty)
                        Text(
                            ' *Maksimal ${data.maksimalPilihKelompokUjian} pilihan',
                            textScaleFactor: context.textScale11,
                            style: context.text.labelSmall
                                ?.copyWith(color: context.hintColor)),
                      if (opsiPilihan.isNotEmpty) const SizedBox(height: 8),
                      if (opsiPilihan.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '  Dipilih: ${kelompokUjianPilihan.length}'
                                '/${data.maksimalPilihKelompokUjian}',
                                textScaleFactor: context.textScale12,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: (kelompokUjianPilihan.length <
                                        data.minimumPilihKelompokUjian)
                                    ? null
                                    : _simpanPilihan,
                                child: Text(
                                    '${widget.isFromTOBK ? 'Konfirmasi' : 'Simpan'} '
                                    'Mata Uji Pilihan'),
                              ),
                            ),
                          ],
                        )
                    ],
                  );
                });
          },
        ),
      ),
    );
  }

  Future<void> _simpanPilihan() async {
    bool isTersimpan = await context
        .read<ProfileProvider>()
        .simpanKelompokUjianPilihan(
          noRegistrasi: context.read<AuthOtpProvider>().userData!.noRegistrasi,
        );

    final duration =
        Duration(seconds: 2, milliseconds: gDelayedNavigation.inMilliseconds);
    await Future.delayed(duration).then(
      (_) => Navigator.pop(context, isTersimpan),
    );
  }

  Center _buildDecoration(BuildContext context) => Center(
        child: Container(
          width: min(200, context.dw * 0.26),
          height: min(8, context.dp(6)),
          decoration: BoxDecoration(
              color: context.disableColor,
              borderRadius: BorderRadius.circular(60)),
        ),
      );

  Row _buildHeader(BuildContext context,
          Map<int, Map<String, String>> opsiPilihan, String tingkatSekolah) =>
      Row(
        children: [
          Icon(
            Icons.checklist_rounded,
            color: context.primaryColor,
            size: min(34, context.dp(32)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              textScaleFactor: context.textScale12,
              text: TextSpan(
                  text: (widget.isFromTOBK)
                      ? 'Konfirmasi Mata Uji Pilihan\n'
                      : 'Mata Uji Pilihan\n',
                  style: context.text.titleMedium,
                  children: [
                    TextSpan(
                        text: (opsiPilihan.isEmpty)
                            ? 'Saat ini belum ada pilihan mata uji untuk tingkat $tingkatSekolah Sobat. '
                                'Hubungi MinGO untuk informasi lebih lanjut yaa!'
                            : (widget.isFromTOBK)
                                ? 'Pilih dengan hati-hati ya Sobat. Pilihan mata uji ini akan menjadi acuan '
                                    'isi TryOut berdasarkan mata uji peminatan yang Sobat pelajari di sekolah. '
                                    'Pilihan yang sudah di konfirmasi tidak dapat diubah kembali untuk '
                                    'TryOut ini ya.'
                                : 'Pilih mata uji pilihan sesuai dengan peminatan kamu di sekolah yaa Sobat!',
                        style: context.text.labelMedium
                            ?.copyWith(color: context.hintColor))
                  ]),
            ),
          ),
        ],
      );

  Widget _buildOptionKelompokUjian(BuildContext context,
          {required VoidCallback onClick,
          required String label,
          required bool isActive}) =>
      InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular((context.isMobile) ? 8 : 12),
        child: Container(
          margin: EdgeInsets.all(min(8, context.dp(6))),
          padding: EdgeInsets.symmetric(
            vertical: min(12, context.dp(10)),
            horizontal: min(14, context.dp(12)),
          ),
          decoration: BoxDecoration(
              color: isActive ? context.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular((context.isMobile) ? 8 : 12),
              border: Border.all(
                  color: isActive ? Colors.transparent : context.onBackground)),
          child: Text(
            label,
            textScaleFactor: min(context.ts, 1.16),
            style: context.text.bodySmall?.copyWith(
                color: isActive ? context.onPrimary : context.onBackground),
          ),
        ),
      );

  Widget _buildOpsiPilihanKelompokUjian(
      Map<int, Map<String, String>> opsiPilihan,
      List<KelompokUjian> kelompokUjianPilihan) {
    return Wrap(
      children: opsiPilihan.entries
          .map<Widget>((opsi) => _buildOptionKelompokUjian(
                context,
                onClick: () async {
                  await context
                      .read<ProfileProvider>()
                      .updateKelompokUjianPilihan(kelompokUjian: opsi);

                  logger.log('PILIHAN_KELOMPOK_UJIAN: $opsi');
                },
                label: opsi.value['nama'] ?? '-',
                isActive: kelompokUjianPilihan
                    .any((pilihan) => pilihan.idKelompokUjian == opsi.key),
              ))
          .toList(),
    );
  }
}
