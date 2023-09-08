import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../list_ranking.dart';
import '../../provider/leaderboard_racing_provider.dart';
import '../../../service/api/apiranking.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';

class SemesterRacing extends StatefulWidget {
  final String level;

  const SemesterRacing({super.key, required this.level});
  @override
  State<SemesterRacing> createState() => _SemesterRacing();
}

class _SemesterRacing extends State<SemesterRacing> {
  int selisihmonth = 0;
  int? currentsemester;
  int? currentmonth;
  bool _loading = true;
  bool _hasiltopfive = false;
  bool _hasilmyrank = false;
  int? selectedsemester;
  String? tanggaltampil;
  Timer? _timer;
  DateTime? now;
  DataRanking dataRanking = DataRanking();
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();
  @override
  void initState() {
    super.initState();
    now = DateTime.now();

    currentmonth = now?.month;
    currentsemester = currentmonth! < 7 ? 1 : 2;
    selectedsemester = currentsemester;
    tanggaltampil = currentsemester.toString();
    delay();
  }

  delay() {
    _timer = Timer(const Duration(milliseconds: 1000), () {
      getdata();
    });
  }

  /// [getdata] adalah fungsi untuk mendapatkan data dari API.
  void getdata() async {
    final nis = _authProvider.userData?.noRegistrasi;
    final idsekolahkelas = _authProvider.userData?.idSekolahKelas;
    final penanda = _authProvider.userData?.idKota;
    final idgedung = _authProvider.userData?.idGedung;
    final ta = _authProvider.tahunAjaran;
    ApiRanking api = ApiRanking();

    Map<String, dynamic> data = await api.getranking(
      idSekolahKelas: idsekolahkelas!,
      idgedung: idgedung!,
      jeniswaktu: "semester",
      level: widget.level,
      nis: nis!,
      number: selectedsemester!,
      penanda: penanda!,
      ta: ta,
    );

    if (data['status']) {
      setState(() {
        dataRanking = data['data'];
        dataRanking.topfive == null
            ? _hasiltopfive = false
            : _hasiltopfive = true;
        dataRanking.myrank == null ? _hasilmyrank = false : _hasilmyrank = true;
        _loading = false;
      });
    } else {
      setState(() {
        _hasiltopfive = false;
        _hasilmyrank = false;
        _loading = false;
      });
    }
  }

  /// Fungsi di atas digunakan untuk mengubah semester.
  ///
  /// args:
  /// add (bool): Benar jika pengguna menggeser ke kanan, false jika pengguna menggeser ke kiri.
  void proses(bool add) {
    _timer?.cancel();
    selectedsemester = selectedsemester == 1 ? 2 : 1;
    setState(() {
      _loading = true;
      _hasiltopfive = false;
      _hasilmyrank = false;
      tanggaltampil = selectedsemester.toString();
    });

    delay();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding: EdgeInsets.only(
            left: context.dp(20),
            right: context.dp(20),
            bottom: context.dp(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                  onTap: () => proses(false),
                  child: Icon(
                    Icons.arrow_circle_left_outlined,
                    size: 24,
                    color:
                        (context.isMobile) ? context.background : Colors.black,
                  )),
              Text(
                tanggaltampil!,
                style: context.text.bodyMedium?.copyWith(
                  color: (context.isMobile) ? context.background : Colors.black,
                ),
              ),
              InkWell(
                onTap: () => proses(true),
                child: Icon(
                  Icons.arrow_circle_right_outlined,
                  size: 24,
                  color: (context.isMobile) ? context.background : Colors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: context.dw,
            padding: const EdgeInsets.only(right: 12, left: 12),
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: _loading
                ? const LoadingWidget()
                : (dataRanking.myrank!.isEmpty && dataRanking.topfive!.isEmpty)
                    ? const NoDataFoundWidget(
                        subTitle: "Leaderboard Racing",
                        emptyMessage:
                            "Data masih kosong, ayo kerjakan soal racing Sobat")
                    : SingleChildScrollView(
                        child: Container(
                          width: context.dw,
                          padding: EdgeInsets.only(top: context.pd),
                          child: Column(
                            children: [
                              SizedBox(
                                height: context.pd,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: Text(
                                        "Rank",
                                        style: context.text.bodySmall?.copyWith(
                                            color: context.hintColor),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Nama Siswa",
                                            style: context.text.bodySmall
                                                ?.copyWith(
                                                    color: context.hintColor),
                                          ),
                                          Text(
                                            "Skor",
                                            style: context.text.bodySmall
                                                ?.copyWith(
                                                    color: context.hintColor),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              _hasiltopfive
                                  ? LeaderboardRacingListRank(
                                      context: context,
                                      dataRanking: dataRanking.topfive!)
                                  : Text(
                                      "Data kosong",
                                      style: context.text.bodyMedium
                                          ?.copyWith(color: context.hintColor),
                                    ),
                              SizedBox(
                                height: 50,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Expanded(child: Divider()),
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: context.dw - 32),
                                      padding: const EdgeInsets.only(
                                          right: 12, left: 12),
                                      child: Text(
                                        "Ranking Terdekat",
                                        style:
                                            context.text.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                              ),
                              _hasilmyrank
                                  ? LeaderboardRacingListRank(
                                      context: context,
                                      dataRanking: dataRanking.myrank!)
                                  : Container()
                            ],
                          ),
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}
