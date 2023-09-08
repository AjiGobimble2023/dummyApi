import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import '../list_ranking.dart';
import '../../provider/leaderboard_racing_provider.dart';
import '../../../service/api/apiranking.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';

class BulanRacing extends StatefulWidget {
  final String? level;

  const BulanRacing({super.key, @required this.level});
  @override
  State<BulanRacing> createState() => _BulanRacing();
}

class _BulanRacing extends State<BulanRacing> {
  int selisihmonth = 0;
  int? currentmonth;
  bool _loading = true;
  bool _hasiltopfive = false;
  bool _hasilmyrank = false;
  int? selectedmonth;
  String? tanggaltampil;
  Timer? _timer;
  DateTime? now;
  DataRanking dataRanking = DataRanking();
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();
  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    var formatter = DateFormat('MMM yyyy');
    currentmonth = now!.month;
    selectedmonth = currentmonth;
    tanggaltampil = formatter.format(now!);
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
      jeniswaktu: "bulan",
      level: widget.level!,
      nis: nis!,
      number: selectedmonth!,
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

  /// [proses] adalah fungsi yang digunakan untuk mengubah kisaran bulan.
  ///
  /// args:
  /// add (bool): boolean, jika benar, bulan akan ditambahkan, jika false, bulan akan dikurangi
  void proses(bool add) {
    _timer?.cancel();
    add ? selisihmonth++ : selisihmonth--;
    setState(() {
      var jiffy = Jiffy.now().add(months: selisihmonth);
      _loading = true;
      _hasiltopfive = false;
      _hasilmyrank = false;
      selectedmonth = Jiffy.now().add(months: selisihmonth).month;
      tanggaltampil = jiffy.format(pattern: 'MMM yyyy');
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
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding: EdgeInsets.only(
              left: context.dp(20),
              right: context.dp(20),
              bottom: context.dp(20)),
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
                    ? SingleChildScrollView(
                        child: SizedBox(
                          height: context.dh,
                          child: NoDataFoundWidget(
                              subTitle: "Leaderboard Racing",
                              isLandscape: !context.isMobile,
                              emptyMessage:
                                  "Data masih kosong, ayo kerjakan soal racing Sobat"),
                        ),
                      )
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
