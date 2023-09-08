// ignore_for_file: use_build_context_synchronously

import 'dart:developer' as logger show log;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/dialog/custom_dialog.dart';
import '../../../../../../core/shared/widget/chart/radar_chart_widget.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../model/laporan_tryout_nilai_model.dart';
import '../../model/laporan_tryout_pilihan_model.dart';
import '../provider/laporan_tryout_provider.dart';

class LaporanTryoutSNBTProfilNilai extends StatefulWidget {
  const LaporanTryoutSNBTProfilNilai(this.namaTOB, this._data, this.link,
      {super.key});
  final String namaTOB;
  final Map<String, dynamic> _data;
  final String link;

  @override
  State<LaporanTryoutSNBTProfilNilai> createState() =>
      _LaporanTryoutSNBTProfilNilai();
}

class _LaporanTryoutSNBTProfilNilai
    extends State<LaporanTryoutSNBTProfilNilai> {
  /// var Controller
  final _screenshootController = ScreenshotController();
  final ScrollController scrollController = ScrollController();

  /// var initialize data user
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  /// var choice list menu
  final List<List<dynamic>> _feedAction = [
    ["Feed", const Icon(Icons.send_rounded)],
    ["Share", const Icon(Icons.share)],
  ];

  @override
  Widget build(BuildContext context) {
    /// var initialize data kampus impian dan detail nilai
    final listPilihan =
        widget._data['pilihan'] as List<LaporanTryoutPilihanModel>;
    final listNilai = widget._data['nilai'] as List<LaporanTryoutNilaiModel>;

    /// var [nilaiMax] merupakan patokan nilai tertinggi yang didapatkan oleh seorang siswa dalam satu kelompok ujian
    final nilaiMax =
        listNilai.map((val) => double.parse(val.nilaiMax).toInt()).toList();

    /// var initialize data siswa dan data nilai TO
    final userId = _authProvider.userData!.noRegistrasi;
    final nilaiSiswa =
        listNilai.map((val) => double.parse(val.nilai).toInt()).toList();

    /// var [labelNilai] merupakan konversi data dari initial/singkatan nama kelompok ujian menjadi nama kelompok
    final List<String> labelNilai = List<String>.from(listNilai.map((val) {
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
    }).toList());

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
            left: context.pd,
            right: context.isMobile ? context.pd : context.pd / 2,
            bottom: context.pd,
            top: context.isMobile ? 5 : context.pd),
        width: context.dw / 2,
        child: Column(
          children: <Widget>[
            /// Widget Radar Chart Nilai Siswa
            _buildChart(
              namaTOB: widget.namaTOB,
              listNilaiMax: nilaiMax,
              listNilaiSiswa: nilaiSiswa,
              listLable: labelNilai,

              /// [_bottomSheetSetting] bottomsheet untuk menampilkan pilihan untuk share grafik nilai TO
              bottomSheet: _bottomSheetSetting(
                nilaiMax,
                nilaiSiswa,
                labelNilai,
                userId,
                _buildChart(
                  namaTOB: widget.namaTOB,
                  listNilaiMax: nilaiMax,
                  listNilaiSiswa: nilaiSiswa,
                  listLable: labelNilai,
                ),
                _buildPilihanList(context, listPilihan),
              ),
            ),
            SizedBox(
              height: context.pd / 2,
            ),

            /// Widget Kampus Impian pilihan 1 dan 2
            buildInformasiUmum(context, listPilihan, 0),
            SizedBox(
              height: context.pd / 2,
            ),
            buildInformasiUmum(context, listPilihan, 1),
          ],
        ),
      ),
    );
  }

  /// The above function is a function that is used to build the chart.
  ///
  /// Args:
  ///   namaTOB (String): The name of the TOB
  ///   listNilaiMax (List<int>): The maximum value of the chart
  ///   listNilaiSiswa (List<int>): List of student scores
  ///   listLable (List<String>): List of labels for each axis.
  ///   bottomSheet (Widget): The bottom sheet that will be displayed when the user clicks on the "more"
  /// icon.
  ///
  /// Returns:
  ///   A Container widget with a Column child.
  Widget _buildChart({
    String? namaTOB,
    List<int>? listNilaiMax,
    List<int>? listNilaiSiswa,
    List<String>? listLable,
    Widget? bottomSheet,
  }) {
    return Container(
      padding: EdgeInsets.all(context.pd),
      decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: kElevationToShadow[1]),
      child: Column(
        children: [
          Row(
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
                  Icons.radar_rounded,
                  size: (context.isMobile) ? context.dp(22) : context.dp(16),
                  color: context.onTertiary,
                ),
              ),
              Expanded(
                child: (context.isMobile)
                    ? RichText(
                        textScaleFactor: context.textScale12,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "PROFIL NILAI\n",
                              style: context.text.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text: widget.namaTOB,
                              style: context.text.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : RichText(
                        textScaleFactor: context.textScale12,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "PROFIL NILAI\n",
                              style: context.text.labelLarge,
                            ),
                            TextSpan(
                              text: widget.namaTOB,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.hintColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25.0),
                        ),
                      ),
                      builder: (feedcontext) => bottomSheet!,
                    );
                  },
                  child: const Icon(Icons.more_vert_rounded)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Divider(),
          ),
          SizedBox(
            height: (context.isMobile) ? 300 : 450,
            width: (context.isMobile) ? 300 : 450,
            child: RadarChartWidget(
              values: [listNilaiMax!, listNilaiSiswa!],
              lables: listLable,
              colors: [Colors.green.shade700, Colors.red.shade700],
              ticks: const [200, 400, 600, 800, 1050],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Chip(
                  label: Text(
                    'Skor Maks.',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.onPrimary),
                  ),
                  backgroundColor: Palette.kSuccessSwatch),
              Chip(
                  label: Text(
                    'Skor',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.onPrimary),
                  ),
                  backgroundColor: context.primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  /// The above function is used to build the information of the selected college.
  ///
  /// Args:
  ///   context (BuildContext): BuildContext
  ///   listPilihan (List<LaporanTryoutPilihanModel>): List of LaporanTryoutPilihanModel
  ///   i (int): index of the list
  Widget buildInformasiUmum(BuildContext context,
      List<LaporanTryoutPilihanModel> listPilihan, int i) {
    return Container(
      padding: EdgeInsets.all(context.pd),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: kElevationToShadow[2],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: context.isMobile ? context.dw : context.dw / 2,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 0,
              minVerticalPadding: 0,
              leading: Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: context.tertiaryColor,
                  shape: BoxShape.circle,
                  boxShadow: kElevationToShadow[2],
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  size: (context.isMobile) ? context.dp(22) : context.dp(16),
                  color: context.onTertiary,
                ),
              ),
              title: Text(
                listPilihan[i].ptn,
                style: context.text.labelLarge,
              ),
              subtitle: Text(
                listPilihan[i].jurusan,
                style: context.text.bodyMedium,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 0,
            ),
          ),
          Row(
            children: <Widget>[
              const Expanded(flex: 1, child: Text('Passing Grade')),
              Expanded(
                  flex: 2,
                  child: Text(
                      ': ${double.parse(listPilihan[i].pg).toStringAsFixed(2)}')),
            ],
          ),
          Row(
            children: <Widget>[
              const Expanded(flex: 1, child: Text('Nilai Siswa')),
              Expanded(flex: 2, child: Text(': ${listPilihan[i].nilai}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeed({
    List<int>? listNilaiMax,
    List<int>? listNilaiSiswa,
    List<String>? listLable,
  }) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.blue,
        image: DecorationImage(
          image: AssetImage("assets/img/bg-tobk.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Container(
            clipBehavior: Clip.antiAlias,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Container(
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/img/logo.webp",
                      width: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Profil Nilai ${widget.namaTOB}',
                  style: context.text.labelLarge,
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: RadarChartWidget(
                        values: [
                          listNilaiMax!,
                          listNilaiSiswa!,
                        ],
                        lables: listLable,
                        colors: [
                          Colors.green.shade700,
                          Colors.red.shade700,
                        ],
                        ticks: const [200, 400, 600, 800, 1050],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPilihanList(
      BuildContext context, List<LaporanTryoutPilihanModel> listPilihan) {
    List<Widget> listPilihanWidget = [];
    for (int i = 0; i < listPilihan.length; i++) {
      listPilihanWidget.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width:
                    context.isMobile ? context.dw - 20 : (context.dw / 2) - 20,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(4),
                    margin: EdgeInsets.only(right: context.dp(12)),
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
                      Icons.apartment_rounded,
                      size: context.dp(22),
                      color: context.onTertiary,
                    ),
                  ),
                  title: Text(
                    listPilihan[i].ptn,
                    style: context.text.labelLarge,
                  ),
                  subtitle: Text(
                    listPilihan[i].jurusan,
                    style: context.text.bodyMedium,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 2, bottom: 2),
                child: Divider(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Expanded(flex: 1, child: Text('PTN')),
                  Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(": "),
                          Text(listPilihan[i].ptn),
                        ],
                      )),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Expanded(flex: 1, child: Text('Pilihan Prodi')),
                  Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(": "),
                          Flexible(child: Text(listPilihan[i].jurusan)),
                        ],
                      )),
                ],
              ),
              Row(
                children: <Widget>[
                  const Expanded(flex: 1, child: Text('Passing Grade')),
                  Expanded(
                      flex: 2,
                      child: Text(
                          ': ${double.parse(listPilihan[i].pg).toStringAsFixed(2)}')),
                ],
              ),
              Row(
                children: <Widget>[
                  const Expanded(flex: 1, child: Text('Nilai Siswa')),
                  Expanded(flex: 2, child: Text(': ${listPilihan[i].nilai}')),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        buildInformasiUmum(context, listPilihan, 0),
        const SizedBox(
          height: 10,
        ),
        buildInformasiUmum(context, listPilihan, 1),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  /// The above function is a function that is used to display the bottom sheet setting.
  ///
  /// Args:
  ///   nilaiMax: List of maximum scores
  ///   nilaiSiswa: List of student scores
  ///   labelNilai: List of labels for each chart
  ///   userId: userId,
  ///   chartWidget: Widget
  ///   pilihanWidget: Widget
  ///
  /// Returns:
  ///   Widget _buildFeed(
  ///       {List<double> listNilaiMax,
  ///       List<double> listNilaiSiswa,
  ///       List<String> listLable}) {
  ///     return Container(
  ///       width: context.dw,
  ///       height: context.dw,
  ///       child: Column(
  ///         children:
  Widget _bottomSheetSetting(
      nilaiMax, nilaiSiswa, labelNilai, userId, chartWidget, pilihanWidget) {
    return Container(
      padding: EdgeInsets.only(
        left: context.dp(12),
        right: context.dp(12),
      ),
      width: context.dw,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: context.dp(40),
              height: context.dp(4),
              margin: EdgeInsets.symmetric(vertical: context.dp(8)),
              decoration: BoxDecoration(
                  color: context.disableColor,
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          CupertinoScrollbar(
            controller: scrollController,
            radius: const Radius.circular(14),
            child: ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: _feedAction.length,
              itemBuilder: (feedcontext, index) {
                if (kDebugMode) {
                  logger.log(_feedAction[index][0].toString());
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        switch (_feedAction[index][0]) {
                          case "Feed":
                            {
                              try {
                                CustomDialog.loadingDialog(context);
                                final image = await _screenshootController
                                    .captureFromWidget(_buildFeed(
                                  listNilaiMax: nilaiMax,
                                  listNilaiSiswa: nilaiSiswa,
                                  listLable: labelNilai,
                                ));
                                final directory =
                                    await getApplicationDocumentsDirectory();
                                final imagePath =
                                    await File('${directory.path}/image.png')
                                        .create();
                                await imagePath.writeAsBytes(image);
                                const caption =
                                    "[FLEXING TRYOUT]\nHai guys, saya dapat nilai tryout segini loh!\nJangan mau kalah ya Sobat";
                                final file64 =
                                    base64Encode(imagePath.readAsBytesSync());

                                await context
                                    .read<LaporanTryoutProvider>()
                                    .uploadFeed(
                                      userId: userId,
                                      content: caption,
                                      file64: file64,
                                    );

                                gShowTopFlash(
                                    context, "Berhasil membuat Feed Nilai TO",
                                    dialogType: DialogType.success);
                                Navigator.pop(feedcontext);
                                Navigator.pop(context);
                              } catch (_) {
                                Navigator.pop(feedcontext);
                                gShowTopFlash(
                                    context, "Gagal membuat Feed Nilai TO",
                                    dialogType: DialogType.warning);
                              }
                            }
                            break;

                          case "Share":
                            {
                              Navigator.of(context).pushNamed(
                                Constant.kRouteLaporanTryOutShare,
                                arguments: {
                                  'chart': chartWidget,
                                  'pilihan': pilihanWidget
                                },
                              );
                            }
                            break;
                        }
                      },
                      child: ListTile(
                        title: Text(
                          _feedAction[index][0],
                          style: context.text.bodyMedium,
                        ),
                        leading: _feedAction[index][1],
                        minLeadingWidth: context.dp(0),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
