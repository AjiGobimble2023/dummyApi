import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../model/laporan_tryout_nilai_model.dart';
import '../../provider/laporan_tryout_provider.dart';

class LaporanTryoutLaporanAKMWidget extends StatefulWidget {
  final String? namaTOB;
  final String? kodeTOB;
  final String? penilaian;

  const LaporanTryoutLaporanAKMWidget(
      {Key? key, this.namaTOB, this.kodeTOB, this.penilaian})
      : super(key: key);

  @override
  State<LaporanTryoutLaporanAKMWidget> createState() =>
      _LaporanTryoutLaporanAKMWidgetState();
}

class _LaporanTryoutLaporanAKMWidgetState
    extends State<LaporanTryoutLaporanAKMWidget> {
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  Widget _buildNilaiList(List<LaporanTryoutNilaiModel> listNilai) {
    List<Widget> listNilaiWidget = [];

    for (int i = 0; i < listNilai.length; i++) {
      listNilaiWidget.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor)),
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
                  Text(listNilai[i].nilai,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text('Benar : ${listNilai[i].benar}'),
              Text('Salah : ${listNilai[i].salah}'),
              Text('Kosong : ${listNilai[i].kosong}'),
              const SizedBox(height: 10.0),
              Text('Full Credit : ${listNilai[i].fullCredit}'),
              Text('Half Credit : ${listNilai[i].halfCredit}'),
              Text('Zero Credit : ${listNilai[i].zeroCredit}'),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: listNilaiWidget,
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
                        _buildNilaiList(snapshot.data!['nilai']),
                      ],
                    )
              : const LoadingWidget(),
    );
  }
}
