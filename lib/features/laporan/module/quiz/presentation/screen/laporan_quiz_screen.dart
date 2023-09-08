import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/laporan_kuis_provider.dart';
import '../widget/detail_nilai_kuis_widget.dart';
import '../widget/category_and_score_widget.dart';
import '../../model/laporan_kuis_model.dart';
import '../../../../../soal/entity/detail_jawaban.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/helper/firebase_helper.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';

class LaporanQuizScreen extends StatefulWidget {
  const LaporanQuizScreen({super.key});

  @override
  State<LaporanQuizScreen> createState() => _LaporanQuizScreenState();
}

class _LaporanQuizScreenState extends State<LaporanQuizScreen> {
  /// [_authProvider] merupakan variable provider
  /// yang diperlukan untuk memanggil data login user
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  /// [listkodesoal] merupakan variable yang menampung data list kode soal
  List<Info> listkodesoal = [];

  /// [listAnswer] merupakan variable yang menampung data list jawaban siswa
  List<DetailJawaban> listAnswer = [];

  /// Kumpulan variable initialize data user
  String? noRegistrasi, idSekolahKelas, userType, ta;

  /// Kumpulan variable picker dan nilai awal nya
  int selectedindexmapel = 0;
  int selectedindexkode = 0;
  String kodesoalterpilih = "Pilih Kode Soal";
  String mapelterpilih = "Pilih Mata Pelajaran";

  /// Kumpulan variable untuk memeriksa kondisi data
  bool isloading = false;
  bool kosongkah = true;
  bool adanilai = false;

  /// [scrollController] merupakan controller untuk scroll bottomSheet picker
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    /// Initialization data Siswa
    noRegistrasi = _authProvider.userData!.noRegistrasi;
    idSekolahKelas = _authProvider.userData!.idSekolahKelas;
    userType = _authProvider.userData!.siapa;
    ta = Constant.kTahunAjaran;

    /// [getLaporanKuis] Untuk mendapatkan list Mapel kuis yang telah dikerjakan
    Future.delayed(Duration.zero, () async {
      await context.read<LaporanKuisProvider>().getLaporanKuis(
          noRegistrasi: noRegistrasi!,
          idSekolahKelas: idSekolahKelas!,
          tahunAjaran: ta!);
    });
  }

  /// [getJawabanSiswa] merupakan method untuk mendapatkan nilai kuis siswa
  getJawabanSiswa(String kodePaket) async {
    setState(() {
      isloading = true;
    });
    if (kodesoalterpilih != "Pilih Kode Soal") {
      Timer(const Duration(milliseconds: 1000), () async {
        final firebaseHelper = FirebaseHelper();
        listAnswer = await firebaseHelper.getJawabanSiswaByKodePaket(
          tahunAjaran: Constant.kTahunAjaran,
          noRegistrasi: noRegistrasi!,
          idSekolahKelas: idSekolahKelas!,
          tipeUser: userType!,
          kodePaket: kodePaket,
        );
        setState(() {
          if (listAnswer.isNotEmpty) adanilai = true;
          isloading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> kategori = gettotal();
    return Consumer<LaporanKuisProvider>(
      builder: (context, value, child) => (value.isLoading)
          ? SizedBox(
              height: context.dh,
              child: const LoadingWidget(),
            )
          : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(context.pd),
              child: Consumer<LaporanKuisProvider>(
                  builder: (context, value, _) => Column(
                        children: [
                          /// LaporanKuisPicker merupakan widget
                          /// untuk memilih mata pelajaran dan kode soal
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () async {
                                  if (value.list.isEmpty) {
                                    await gShowBottomDialogInfo(context,
                                        message:
                                            "Sobat belum ada mengerjakan Soal Kuis, Ayo kerjakan soal kuis sekarang!");
                                    return;
                                  }
                                  final selectedType =
                                      await bottomSheetMapel(
                                          context, value);
                                  if (selectedType != null) {
                                    setState(() {
                                      if (listkodesoal.isNotEmpty) {
                                        listkodesoal = [];
                                      }
                                      selectedindexmapel = selectedType;
                                      mapelterpilih = value
                                          .list[selectedindexmapel]
                                          .cnamamapel!;
                                      listkodesoal = value
                                          .list[selectedindexmapel].info!;
                                      if (listkodesoal.isNotEmpty) {
                                        if (listkodesoal[0].cKodeSoal !=
                                            "Pilih Kode Soal") {
                                          Info f = Info(
                                              cKodeSoal: "Pilih Kode Soal");
                                          listkodesoal.insert(0, f);
                                        }
                                      }
                                    });
                                    selectedindexkode = 0;
                                  }
                                },
                                child: Container(
                                  padding: context.isMobile
                                      ? EdgeInsets.zero
                                      : EdgeInsets.all(context.dp(4)),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        gDefaultShimmerBorderRadius,
                                    border: Border.all(
                                        color: context.disableColor),
                                  ),
                                  child: ListTile(
                                    title: Text('Mata Pelajaran',
                                        style: context.text.bodyMedium),
                                    subtitle: Text(
                                      mapelterpilih,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    trailing: const Icon(Icons.edit),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: context.isMobile
                                    ? context.dp(12)
                                    : context.dp(6),
                              ),
                              InkWell(
                                onTap: () async {
                                  if (selectedindexmapel == 0) {
                                    await gShowBottomDialogInfo(context,
                                        message:
                                            "Pilih Mata Pelajarannya terlebih dahulu Sobat");
                                    return;
                                  }

                                  final selectedType =
                                      await bottomSheetKodeSoal(context);

                                  if (selectedType != null) {
                                    setState(() {
                                      selectedindexkode = selectedType;
                                      kodesoalterpilih =
                                          listkodesoal[selectedindexkode]
                                              .cKodeSoal!;
                                      if (selectedindexkode > 0) {
                                        getJawabanSiswa(kodesoalterpilih);
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  padding: context.isMobile
                                      ? EdgeInsets.zero
                                      : EdgeInsets.all(context.dp(4)),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          gDefaultShimmerBorderRadius,
                                      border: Border.all(
                                          color: context.disableColor)),
                                  child: ListTile(
                                    title: Text('Kode Soal',
                                        style: context.text.bodyMedium),
                                    subtitle: Text(
                                      kodesoalterpilih,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    trailing: const Icon(Icons.edit),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          /// [KategoriScoreAndChartWidget] merupakan widget
                          /// untuk menampilkan nilai siswa dalam bentuk chart
                          /// dan kategori nilai kuis
                          (isloading)
                              ? SizedBox(
                                  height: context.dh - 300,
                                  child: const LoadingWidget())
                              : Column(
                                  children: [
                                    (listAnswer.isNotEmpty)
                                        ? SizedBox(
                                            height: 500,
                                            child:
                                                KategoriScoreAndChartWidget(
                                              mapel: mapelterpilih,
                                              kodeSoal: kodesoalterpilih,
                                              listJawaban: listAnswer,
                                              kategori: kategori,
                                            ),
                                          )
                                        : const SizedBox.shrink(),

                                    /// [DetailNilaiKuisWidget] merupakan widget
                                    /// untuk menampilkan nilai siswa dalam bentuk tabel
                                    (listAnswer.isNotEmpty)
                                        ? DetailNilaiKuisWidget(
                                            listJawaban: listAnswer,
                                            kategori: kategori,
                                          )
                                        : const SizedBox.shrink(),
                                    (listAnswer.isEmpty)
                                        ? (kodesoalterpilih ==
                                                    'Pilih Kode Soal' ||
                                                mapelterpilih ==
                                                    'Pilih Mata Pelajaran')
                                            ? SizedBox(
                                                height: context.dh - 200,
                                                child: BasicEmpty(
                                                  shrink: true,
                                                  // isLandscape: !context.isMobile,
                                                  imageUrl:
                                                      'ilustrasi_soal_quiz.png'
                                                          .illustration,
                                                  title: 'Laporan Kuis',
                                                  subTitle:
                                                      'Pantau hasil kuis Sobat disini',
                                                  emptyMessage: (kodesoalterpilih ==
                                                              "Pilih Kode Soal" ||
                                                          mapelterpilih ==
                                                              "Pilih Mata Pelajaran")
                                                      ? "Pilih Mata Pelajaran dan kode soal terlebih dahulu"
                                                      : "Sepertinya sobat belum mengerjakan $kodesoalterpilih",
                                                ),
                                              )
                                            : SingleChildScrollView(
                                                child: NoDataFoundWidget(
                                                    shrink: true,
                                                    subTitle:
                                                        'Sepertinya sobat belum mengerjakan kuis $mapelterpilih($kodesoalterpilih)',
                                                    emptyMessage:
                                                        'Ayo kerjakan soal kuis sekarang sobat, dan lihat hasil pencapaian sobat disini'),
                                              )
                                        : const SizedBox.shrink(),
                                  ],
                                )
                        ],
                      )),
            ),
          ),
    );
  }

  /// [bottomSheetKodeSoal] merupakan widget yang menampilkan bottomsheet pilihan mata pelajaran
  Future<int?> bottomSheetMapel(
      BuildContext context, LaporanKuisProvider value) {
    return showModalBottomSheet<int>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          return Container(
            width: context.dw,
            padding: EdgeInsets.only(top: context.pd),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoScrollbar(
                      controller: scrollController,
                      thickness: 4,
                      radius: const Radius.circular(14),
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: value.list.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedindexmapel = index;
                                  });
                                  Navigator.of(context).pop(selectedindexmapel);
                                },
                                child: Container(
                                  width: context.dw,
                                  alignment: Alignment.center,
                                  padding: (context.isMobile)
                                      ? const EdgeInsets.all(8.0)
                                      : EdgeInsets.all(context.pd),
                                  child: Text(
                                    value.list[index].cnamamapel!,
                                    style: context.text.bodyLarge,
                                  ),
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  /// [bottomSheetKodeSoal] merupakan widget yang menampilkan bottomsheet pilihan kode soal
  Future<int?> bottomSheetKodeSoal(BuildContext context) {
    return showModalBottomSheet<int>(
        constraints: BoxConstraints(
          maxWidth:
              (context.isMobile) ? context.dw : context.dw - context.dp(0),
        ),
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          return Container(
            width: context.dw,
            padding: EdgeInsets.only(top: context.pd),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoScrollbar(
                    controller: scrollController,
                    // thumbVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(14),
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: listkodesoal.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedindexkode = index;
                                });
                                Navigator.of(context).pop(selectedindexkode);
                              },
                              child: Padding(
                                padding: (context.isMobile)
                                    ? const EdgeInsets.all(8.0)
                                    : EdgeInsets.all(context.pd),
                                child: Text(
                                  listkodesoal[index].cKodeSoal!,
                                  style: context.text.bodyLarge,
                                ),
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  /// [gettotal] merupakan fungsi untuk menentukan kategori nilai kuis
  Map<String, dynamic> gettotal() {
    Map<String, dynamic> kategori = <String, dynamic>{};
    int ttl = 0;
    Color color = Colors.blue;
    String status = "";
    for (var element in listAnswer) {
      if (element.kunciJawaban == element.jawabanSiswa) ttl = ttl + 20;
    }
    if (ttl <= 40) {
      status = "Waspada";
      color = context.primaryColor;
    } else if (ttl > 40 && ttl < 80) {
      status = "Berjuang";
      color = context.secondaryColor;
    } else {
      status = "Merdeka";
      color = Palette.kSuccessSwatch;
    }
    kategori['status'] = status;
    kategori['nilai'] = ttl;
    kategori['warna'] = color;
    return kategori;
  }
}
