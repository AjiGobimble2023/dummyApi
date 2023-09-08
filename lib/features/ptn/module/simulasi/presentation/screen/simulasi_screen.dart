import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/util/app_exceptions.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../model/nilai_model.dart';
import '../provider/simulasi_pilihan_provider.dart';
import '../provider/simulasi_hasil_provider.dart';
import '../provider/simulasi_nilai_provider.dart';
import '../widget/simulasi_pilihan_widget.dart';
import '../widget/simulasi_hasil_widget.dart';

class SimulasiScreen extends StatefulWidget {
  const SimulasiScreen({Key? key}) : super(key: key);

  @override
  State<SimulasiScreen> createState() => _SimulasiScreenState();
}

class _SimulasiScreenState extends State<SimulasiScreen> {
  /// Creating a variable called stepperType and assigning it the value of StepperType.vertical.
  StepperType stepperType = StepperType.vertical;

  /// Declaring a variable called _currentStep and assigning it the value 0.
  int _currentStep = 0;

  /// [scrollController] is creating a scroll controller.
  final ScrollController scrollController = ScrollController();

  /// [_authProvider] reading the AuthOtpProvider from the Provider.
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// The below code is declaring a data User.
  late final String _noRegistrasi;
  late final String _idSekolahKelas;
  late final String _tingkatKelas;
  late final String _userType;

  @override
  void initState() {
    super.initState();

    /// The below code is getting the user data from the auth provider.
    _noRegistrasi = _authProvider.userData!.noRegistrasi;
    _idSekolahKelas = _authProvider.userData!.idSekolahKelas;
    _tingkatKelas = _authProvider.userData!.tingkatKelas;
    _userType = _authProvider.userData!.siapa;

    /// Calling the prepareData() function.
    prepareData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// [prepareData] is a function that is used to load data from the API.
  prepareData() {
    if (mounted) {
      Future.delayed(Duration.zero, () async {
        await context.read<SimulasiNilaiProvider>().loadNilai(
              noRegistrasi: _noRegistrasi,
              idSekolahKelas: _idSekolahKelas,
            );
        if (!mounted) return;
        await context
            .read<SimulasiPilihanProvider>()
            .loadPilihan(noRegistrasi: _noRegistrasi);
        if (!mounted) return;
        await context.read<SimulasiHasilProvider>().loadSimulasi(
              noRegistrasi: _noRegistrasi,
              userType: _userType,
            );
      });
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulasiNilaiProvider>(
      builder: (ctxNilai, value, child) => (int.parse(_tingkatKelas) < 12)
          ? const NoDataFoundWidget(
              subTitle: "Simulasi SNBT",
              emptyMessage:
                  "Fitur ini hanya bisa digunakan oleh Siswa Tingkat Akhir Sobat")
          : (!value.isLoading && value.listNilai.isEmpty)
              ? const NoDataFoundWidget(
                  subTitle: "Simulasi SNBT",
                  emptyMessage:
                      "Sobat belum memiliki nilai TO untuk di-Simulasikan, Ayo ikuti TO terlebih dahulu Sobat")
              : CustomSmartRefresher(
                  controller: _refreshController,
                  onRefresh: prepareData,
                  isDark: true,
                  child: Stepper(
                    type: stepperType,
                    physics: const ScrollPhysics(),
                    currentStep: _currentStep,
                    onStepContinue: continued,
                    onStepCancel: cancel,
                    controlsBuilder: (context, _) {
                      return Row(
                        children: [
                          (_currentStep != 2)
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: continued,
                                    // (_currentStep != 0)
                                    //     ? continued
                                    //     : (value.isFix)
                                    //         ? continued()
                                    //         : () {
                                    //             confrimDialogSetNilai(
                                    //                 ctxNilai,
                                    //                 value,
                                    //                 context);
                                    //           },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          color: context.primaryColor),
                                      child: Text(
                                        'Lanjut',
                                        style: context.text.labelLarge
                                            ?.copyWith(
                                                color: context.background),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          (_currentStep != 0)
                              ? Container(
                                  padding: (_currentStep == 2)
                                      ? EdgeInsets.zero
                                      : EdgeInsets.only(left: context.pd),
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: cancel,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          color: context.secondaryColor),
                                      child: Text(
                                        'Kembali',
                                        style: context.text.labelLarge
                                            ?.copyWith(color: Colors.black),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      );
                    },
                    steps: <Step>[
                      Step(
                        title: Text(
                          'Pilih Nilai Tryout',
                          style: context.text.titleMedium,
                        ),
                        content: value.isLoading
                            ? loadingShimmer(context)
                            : SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    _buildPeriodePicker(value.listNilai,
                                        value.selectedIndex, value.nilaiModel),
                                    _buildDetailNilai(),
                                  ],
                                ),
                              ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 0
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: Text(
                          'Pilih PTN dan Jurusan',
                          style: context.text.titleMedium,
                        ),
                        content: Consumer<SimulasiPilihanProvider>(
                            builder: (context, val, child) => val.isLoading
                                ? loadingShimmerPTN(context)
                                : Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SimulasiPilihanWidget(
                                        listPilihan: val.listPilihan,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: context.dw,
                                        child: Text(
                                          "*Sobat hanya memiliki 3 kesempatan untuk menentukan PTN & Jurusan yang ingin di-Simulasikan untuk tiap Prioritas",
                                          style: context.text.bodySmall
                                              ?.copyWith(
                                                  color: context.hintColor),
                                          textAlign: TextAlign.left,
                                        ),
                                      )
                                    ],
                                  )),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 1
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: Text(
                          'Simulasi SNBT',
                          style: context.text.titleMedium,
                        ),
                        content: SafeArea(
                          child: Consumer<SimulasiHasilProvider>(
                            builder: (context, val, child) => val.isLoading
                                ? loadingShimmerPTN(context)
                                : Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SimulasiHasilWidget(
                                      listHasil: val.listSimulasi,
                                    ),
                                  ),
                          ),
                          // ),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 2
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                    ],
                  ),
                ),
    );
  }

  /// [confrimDialogSetNilai] fungsi yang digunakan untuk menampilkan dialog konfirmasi saat pengguna menginginkan
  /// untuk menyimpan data nilai yang telah dimasukkan.
  ///
  /// Args:
  ///   ctxNilai (BuildContext): BuildContext of the page where the dialog is called
  ///   value (SimulasiNilaiProvider): SimulasiNilaiProvider
  ///   context (BuildContext): The context of the page where the dialog will be displayed.
  Future<bool> confrimDialogSetNilai(BuildContext ctxNilai,
      SimulasiNilaiProvider value, BuildContext context) {
    return gShowBottomDialog(
      ctxNilai,
      message:
          "Apakah Sobat sudah yakin ini adalah nilai untuk di-Simulasikan?",
      actions: (controller) => [
        TextButton(
          onPressed: () async {
            controller.dismiss(true);
            value.setFixValue(true);

            gShowTopFlash(
              context,
              'Data Nilai Sobat berhasil disimpan',
              dialogType: DialogType.success,
            );
            continued();
          },
          child: const Text('Ya'),
        ),
        TextButton(
          onPressed: () {
            controller.dismiss(true);
          },
          child: const Text('Tidak'),
        )
      ],
    );
  }

  /// [_buildPeriodePicker] adalah fungsi yang digunakan untuk menampilkan daftar TO yang telah diselesaikan
  /// oleh pengguna.
  ///
  /// Args:
  ///   listNilai (List<NilaiModel?>): List data nilai yang akan ditampilkan di menu dropdown
  ///   selectedIndex (int): Indeks item yang dipilih dalam daftar.
  ///   nilaiModel (NilaiModel): NilaiModel
  Widget _buildPeriodePicker(
      List<NilaiModel?>? listNilai, int selectedIndex, NilaiModel nilaiModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        child: Container(
            decoration: BoxDecoration(
                borderRadius: gDefaultShimmerBorderRadius,
                border: Border.all(color: context.disableColor)),
            child: ListTile(
              title: Text('Pilih Tryout', style: context.text.bodyMedium),
              subtitle: Text(
                listNilai![selectedIndex]!.tob,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit),
            )),
        onTap: () async {
          final selectedType = await showModalBottomSheet<int>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0),
                ),
              ),
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: context.dp(24),
                    bottom: context.dp(20),
                    left: context.dp(18),
                    right: context.dp(18),
                  ),
                  child: SizedBox(
                    width: context.dw,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoScrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          thickness: 4,
                          radius: const Radius.circular(14),
                          child: ListView.separated(
                            shrinkWrap: true,
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: listNilai.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  context
                                      .read<SimulasiNilaiProvider>()
                                      .setSelectedIndex(index);
                                  Navigator.of(context).pop();
                                  _onButtonPressed(
                                      listNilai[index]!.detailNilai,
                                      nilaiModel);
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: context.tertiaryColor)),
                                      child: Icon(
                                        Icons.donut_small_rounded,
                                        color: context.tertiaryColor,
                                      )),
                                  title: Text(
                                    listNilai[index]!.tob,
                                    style: context.text.bodyMedium,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });

          if (selectedType != null) {
            if (!mounted) return;
            context
                .read<SimulasiNilaiProvider>()
                .setSelectedIndex(selectedType);
          }
        },
      ),
    );
  }

  /// [loadingShimmer] loading Shimmer Untuk Nilai To
  Widget loadingShimmer(BuildContext context) {
    return Column(
      children: [
        ShimmerWidget.rounded(
          width: context.dw,
          height: 80,
          borderRadius: BorderRadius.circular(24),
        ),
        SizedBox(
          height: context.pd,
        ),
        ShimmerWidget.rounded(
          width: context.dw,
          height: context.dh / 2,
          borderRadius: BorderRadius.circular(24),
        ),
      ],
    );
  }

  /// [loadingShimmerPTN] Loading Shimmer untuk widget pilihan ptn
  Widget loadingShimmerPTN(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 4; i++)
          Padding(
            padding: EdgeInsets.only(bottom: context.pd),
            child: ShimmerWidget.rounded(
              width: context.dw,
              height: 180,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
      ],
    );
  }

  /// [_onButtonPressed] digunakan untuk menyimpan nilai skor yang telah dimasukkan oleh pengguna.
  ///
  /// Args:
  ///   detailNilai (Map<String, dynamic>): Map<String, dynamic>
  ///   nilaiModel (NilaiModel): NilaiModel
  void _onButtonPressed(
      Map<String, dynamic> detailNilai, NilaiModel nilaiModel) async {
    try {
      // CustomDialog.loadingDialog(context);

      await context
          .read<SimulasiNilaiProvider>()
          .saveNilai(
            noRegistrasi: _noRegistrasi,
            kodeTOB: nilaiModel.kodeTob,
            detailNilai: detailNilai,
          )
          .then((_) {
        // gShowTopFlash(context, 'Data nilai berhasil disimpan',
        //     dialogType: DialogType.success);
        // Navigator.pop(context, true);
      });
    } on NoConnectionException catch (_) {
      Navigator.pop(context);
      gShowTopFlash(context, _.toString());
    } on DataException catch (e) {
      gShowTopFlash(context, e.toString());
    } catch (e) {
      gShowTopFlash(context, e.toString());
    }
  }

  /// [_buildDetailNilai] fungsi yang digunakan untuk menampilkan detail nilai
  /// Simulasi.
  Widget _buildDetailNilai() {
    return Consumer<SimulasiNilaiProvider>(
      builder: (_, value, child) => Container(
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.tertiaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Table(
                border: TableBorder.symmetric(
                    inside: const BorderSide(width: 1.0, color: Colors.grey)),
                columnWidths: const <int, TableColumnWidth>{
                  0: FlexColumnWidth(),
                  1: FixedColumnWidth(100),
                },
                children: [
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: const Center(
                          child: Text("Kelompok Ujian",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: const Center(
                          child: Text(
                        "Poin",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                    )
                  ])
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.nilaiModel.detailNilai.length,
              separatorBuilder: (context, index) => const Divider(
                height: 0,
              ),
              itemBuilder: (_, index) {
                final lesson =
                    value.nilaiModel.detailNilai.keys.elementAt(index);
                final nilai = value.nilaiModel.detailNilai[lesson] ?? 0;
                return Table(
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FixedColumnWidth(100),
                  },
                  border: TableBorder.symmetric(
                      inside: const BorderSide(width: 1.0, color: Colors.grey)),
                  children: [
                    TableRow(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Text(lesson),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            nilai.toString(),
                          ),
                        ),
                      ),
                    ])
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// If the current step is less than 2, then increment the current step by 1
  continued() {
    prepareData();
    _currentStep < 2 ? _currentStep += 1 : null;
  }

  /// If the current step is greater than 0, then subtract 1 from the current step
  cancel() {
    prepareData();
    _currentStep > 0 ? _currentStep -= 1 : null;
  }
}
