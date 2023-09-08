import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'jadwal_item_widget.dart';
import '../provider/jadwal_provider.dart';
import '../../entity/jadwal_siswa.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../core/shared/widget/expanded/custom_expansion_tile.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class JadwalListWidget extends StatefulWidget {
  const JadwalListWidget({Key? key}) : super(key: key);

  @override
  State<JadwalListWidget> createState() => _JadwalListWidgetState();
}

class _JadwalListWidgetState extends State<JadwalListWidget> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  Future<List<InfoJadwal>> _getJadwalKBM({bool isRefresh = false}) async {
    return await context.read<JadwalProvider>().loadJadwal(
          isRefresh: isRefresh,
          userType: _authProvider.userData!.siapa,
          noRegistrasi: _authProvider.userData!.noRegistrasi,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<JadwalProvider, List<InfoJadwal>>(
      selector: (_, jadwal) => jadwal.daftarJadwalSiswa,
      // shouldRebuild: (prev, next) => prev.length != next.length || prev.any((prevJadwal) {
      //   var nextJadwal = next.where((jadwal) => jadwal.id == prevJadwal.id)
      // }),
      builder: (context, listJadwalKBM, loadingWidget) =>
          FutureBuilder<List<InfoJadwal>>(
        future: _getJadwalKBM(),
        builder: (context, snapshot) {
          bool isLoadingJadwal =
              snapshot.connectionState == ConnectionState.waiting ||
                  context.select<JadwalProvider, bool>(
                      (jadwal) => jadwal.isLoadingJadwalKBM);
          List<InfoJadwal> daftarJadwal = snapshot.data ?? listJadwalKBM;

          if (isLoadingJadwal) {
            return loadingWidget!;
          }

          Widget basicEmpty = BasicEmpty(
              shrink: (context.dh < 600) ? !context.isMobile : false,
              imageUrl: 'ilustrasi_jadwal_belajar.png'.illustration,
              title: 'Jadwal KBM',
              subTitle: 'Tidak Ada Jadwal KBM',
              emptyMessage:
                  'Saat ini sedang tidak ada jadwal KBM untuk kamu sobat.');

          return CustomSmartRefresher(
            controller: _refreshController,
            onRefresh: () => _getJadwalKBM(isRefresh: true),
            isDark: true,
            child: (daftarJadwal.isEmpty)
                ? ((context.isMobile || context.dh > 600)
                    ? Center(child: basicEmpty)
                    : SingleChildScrollView(child: basicEmpty))
                : _buildListJadwal(daftarJadwal),
          );
        },
      ),
      child: const ShimmerListTiles(isWatermarked: false),
    );
  }

  ListView _buildListJadwal(List<InfoJadwal> daftarJadwal) =>
      ListView.separated(
          itemCount: daftarJadwal.length,
          padding: EdgeInsets.only(top: context.dp(8), bottom: context.dp(48)),
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, index) => CustomExpansionTile(
                title: Text(daftarJadwal[index].tanggal),
                subtitle: Text(
                    'Jumlah Kegiatan: ${daftarJadwal[index].daftarJadwalSiswa.length}'),
                children: daftarJadwal[index]
                    .daftarJadwalSiswa
                    .map<Widget>(
                      (jadwal) => _buildJadwalItem(jadwal),
                    )
                    .toList(),
              ));

  JadwalItemWidget _buildJadwalItem(JadwalSiswa jadwal) => JadwalItemWidget(
        jadwal: jadwal,
        kelasGO: _authProvider.getNamaKelasGOByIdKelas(jadwal.idKelasGO),
      );
}
