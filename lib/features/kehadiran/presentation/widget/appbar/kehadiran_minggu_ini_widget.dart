import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/config/extensions.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../auth/model/user_model.dart';
import '../../../../kehadiran/entity/kehadiran_minggu_ini.dart';
import '../../../../kehadiran/presentation/provider/kehadiran_provider.dart';

class KehadiranMingguIniWidget extends StatefulWidget {
  final UserModel userData;

  const KehadiranMingguIniWidget({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<KehadiranMingguIniWidget> createState() =>
      _KehadiranMingguIniWidgetState();
}

class _KehadiranMingguIniWidgetState extends State<KehadiranMingguIniWidget> {
  late final Future<KehadiranMingguIni> _loadKehadiran =
      context.read<KehadiranProvider>().getKehadiranMingguIni(
            noRegistrasi: widget.userData.noRegistrasi,
          );

  @override
  Widget build(BuildContext context) {
    return Selector<KehadiranProvider, KehadiranMingguIni>(
      selector: (_, provider) => provider.infoKehadiranMingguIni,
      shouldRebuild: (prev, next) =>
          prev.jumlahPertemuan != next.jumlahPertemuan ||
          prev.jumlahHadir != next.jumlahHadir,
      builder: (_, kehadiran, icKehadiran) {
        return FutureBuilder<KehadiranMingguIni>(
          initialData: kehadiran,
          future: _loadKehadiran,
          builder: (context, snapshot) {
            bool isLoading =
                snapshot.connectionState == ConnectionState.waiting ||
                    context.select<KehadiranProvider, bool>(
                        (kehadiran) => kehadiran.isLoadingKehadiran);

            if (isLoading) {
              return ShimmerWidget.rounded(
                width: min(114, context.dp(114)),
                height: min(28, context.dp(28)),
                borderRadius: gDefaultShimmerBorderRadius,
              );
            }

            KehadiranMingguIni kehadiranMingguIni =
                (kehadiran.jumlahPertemuan > -1)
                    ? kehadiran
                    : (snapshot.hasData)
                        ? snapshot.data!
                        : kehadiran;

            return (context.isMobile)
                ? Expanded(
                    child: _buildKehadiranCard(
                        context, icKehadiran!, kehadiranMingguIni),
                  )
                : _buildKehadiranCard(
                    context, icKehadiran!, kehadiranMingguIni);
          },
        );
      },
      child: Image.asset(
        'assets/icon/ic_kehadiran.webp',
        width: min(46, context.dp(28)),
        height: min(46, context.dp(28)),
      ),
    );
  }

  CustomCard _buildKehadiranCard(BuildContext context, Widget icKehadiran,
      KehadiranMingguIni kehadiranMingguIni) {
    return CustomCard(
      // onTap: () => _showLaporanKehadiran(context),
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.only(right: context.dp(12)),
      borderRadius: BorderRadius.circular(32),
      child: Row(
        children: [
          icKehadiran,
          SizedBox(width: min(12, context.dp(4))),
          Expanded(
            child: Column(
              mainAxisSize:
                  (context.isMobile) ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text('Kehadiran Minggu Ini',
                      maxLines: 1,
                      style: context.text.bodySmall?.copyWith(
                          color: context.onBackground, fontSize: 10)),
                ),
                Text(
                  kehadiranMingguIni.jumlahHadir == -1
                      ? "-"
                      : '${kehadiranMingguIni.jumlahHadir}/${kehadiranMingguIni.jumlahPertemuan}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.onBackground, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // void _showLaporanKehadiran(BuildContext context) {
  //   // TODO: Pergi ke Laporan Kehadiran Screen atau tampilkan BottomSheet.
  //   showModalBottomSheet(
  //     context: context,
  //     enableDrag: true,
  //     shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  //     builder: (_) => Padding(
  //       padding: EdgeInsets.only(
  //         right: context.dp(18),
  //         left: context.dp(18),
  //         top: context.dp(24),
  //         bottom: context.dp(24),
  //       ),
  //       child: const Text(
  //         'Belum ada pertemuan kegiatan belajar dan mengajar.',
  //         textAlign: TextAlign.center,
  //       ),
  //     ),
  //   );
  // }
}
