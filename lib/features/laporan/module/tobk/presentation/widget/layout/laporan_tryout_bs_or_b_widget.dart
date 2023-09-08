import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../../core/config/extensions.dart';
import 'package:provider/provider.dart';

import '../../provider/laporan_tryout_provider.dart';
import '../../../model/laporan_tryout_nilai_model.dart';
import '../../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../../core/config/constant.dart';
import '../../../../../../../core/shared/widget/chart/radar_chart_widget.dart';
import '../../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../laporan_detail_nilai_chart.dart';

class LaporanTryoutLaporanBSorBWidget extends StatefulWidget {
  final String? namaTOB;
  final String? kodeTOB;
  final String? penilaian;

  const LaporanTryoutLaporanBSorBWidget({
    super.key,
    this.namaTOB,
    this.kodeTOB,
    this.penilaian,
  });

  @override
  State<LaporanTryoutLaporanBSorBWidget> createState() =>
      _LaporanTryoutLaporanBSorBWidgetState();
}

class _LaporanTryoutLaporanBSorBWidgetState
    extends State<LaporanTryoutLaporanBSorBWidget> {
  /// [_authProvider] variabel provider untuk keperluan get data user
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  /// [_buildNilaiList] merupakan widget untuk menampilkan list Detail nilai siswa
  Widget _buildNilaiList(List<LaporanTryoutNilaiModel>? listNilai) {
    List<Widget> listNilaiWidget = [];
    listNilaiWidget.add(
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 5,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                      color: context.tertiaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(-1, -1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: context.tertiaryColor.withOpacity(0.42)),
                        BoxShadow(
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: context.tertiaryColor.withOpacity(0.42))
                      ]),
                  child: Icon(
                    CupertinoIcons.chart_bar_circle,
                    size: context.dp(22),
                    color: context.onTertiary,
                  ),
                ),
                RichText(
                  textScaleFactor: context.textScale12,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "DETAIL NILAI\n",
                        style: context.text.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: widget.namaTOB!,
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.hintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2, top: 10),
            child: Divider(
              height: 0,
              color: context.hintColor,
            ),
          ),
          for (int i = 0; i < listNilai!.length; i++)
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          listNilai[i].mapel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: context.secondaryColor),
                          child: Text("Nilai : ${listNilai[i].nilai}%",
                              style: context.text.labelLarge)),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: DetailNilaiChart(listJawaban: listNilai[i])),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Visibility(
                      visible: (listNilai.length > 1),
                      child: Divider(
                        height: 0,
                        color: context.hintColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: listNilaiWidget,
      ),
    );
  }

  /// [_buildChart] merupakan widget untuk menampilkan data nilai siswa dalam bentu radar chart
  Widget _buildChart(List<LaporanTryoutNilaiModel>? listNilai, dynamic total) {
    final nilaiSiswa = listNilai!
        .map((val) => (val.benar / val.jumlahSoal * 100) < 0
            ? 0
            : (double.parse(
                    ((val.benar / (val.benar + val.salah + val.kosong)) * 100)
                        .toString())
                .toInt()))
        .toList();

    final labelNilai = listNilai.map((val) {
      return Constant.kInitialKelompokUjian.values
              .where(
                  (element) => element.values.elementAt(0).contains(val.mapel))
              .isNotEmpty
          ? Constant.kInitialKelompokUjian.values
              .where(
                  (element) => element.values.elementAt(0).contains(val.mapel))
              .first
              .values
              .elementAt(1)
          : val.mapel;
    }).toList();
    return Container(
      margin: EdgeInsets.only(
        top: context.dp(16),
        right: context.dp(16),
        left: context.dp(16),
      ),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 2), blurRadius: 4, color: Colors.black26)
          ]),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 5),
            horizontalTitleGap: 0,
            minVerticalPadding: 0,
            title: RichText(
              textScaleFactor: context.textScale12,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "PROFIL NILAI\n",
                    style: context.text.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: widget.namaTOB!,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.hintColor),
                  ),
                ],
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                  color: context.tertiaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(-1, -1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        color: context.tertiaryColor.withOpacity(0.42)),
                    BoxShadow(
                        offset: const Offset(1, 1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        color: context.tertiaryColor.withOpacity(0.42))
                  ]),
              child: Icon(
                Icons.radar_rounded,
                size: context.dp(22),
                color: context.onTertiary,
              ),
            ),
            trailing: GestureDetector(
                onTap: () async {
                  Navigator.of(context).pushNamed(
                    Constant.kRouteLaporanTryOutShare,
                    arguments: {
                      'chart': _buildChart(listNilai, total),
                      'pilihan': const SizedBox.shrink(),
                    },
                  );
                },
                child: const Icon(Icons.more_vert_rounded)),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16, top: 0, left: 16, right: 16),
            child: Divider(
              height: 0,
            ),
          ),
          SizedBox(
            width: 300,
            height: 300,
            child: RadarChartWidget(
              values: [nilaiSiswa],
              lables: List<String>.generate(
                labelNilai.length,
                (index) {
                  return labelNilai[index].toString();
                },
              ),
              colors: [Colors.green.shade700],
              ticks: const [20, 40, 60, 80, 100],
            ),
          ),
          Text(
            'Nilai kamu: $total%',
            style: context.text.labelLarge,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authProvider.userData!.noRegistrasi;
    final userClassLevelId = _authProvider.userData!.idSekolahKelas;
    final userType = _authProvider.userData!.siapa;
    final userPtn1Id = _authProvider.userData!.idJurusanPilihan1.toString();
    final userPtn2Id = _authProvider.userData!.idJurusanPilihan2.toString();
    final kodeTOB = widget.kodeTOB;
    final penilaian = widget.penilaian;
    return FutureBuilder<Map<String, dynamic>>(
      future: context.watch<LaporanTryoutProvider>().loadLaporanNilai(
            userId: userId,
            userClassLevelId: userClassLevelId,
            userType: userType,
            kodeTOB: kodeTOB,
            penilaian: penilaian,
            pilihan1: userPtn1Id,
            pilihan2: userPtn2Id,
          ),
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
              ? snapshot.hasError
                  ? NoDataFoundWidget(
                      subTitle: widget.namaTOB.toString(),
                      emptyMessage:
                          "Laporan Tryout masih belum tersedia saat ini Sobat")
                  : ListView(
                      children: <Widget>[
                        _buildChart(
                            snapshot.data!['nilai'], snapshot.data!['total']),
                        Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            decoration: BoxDecoration(
                                color: context.background,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black26)
                                ]),
                            child: _buildNilaiList(snapshot.data!['nilai'])),
                      ],
                    )
              : const LoadingWidget(),
    );
  }
}
