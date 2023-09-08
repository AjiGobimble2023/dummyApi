import 'dart:developer' as logger show log;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/shared/widget/loading/shimmer_widget.dart';
import 'package:provider/provider.dart';

import '../provider/simulasi_nilai_provider.dart';
import '../../model/nilai_model.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/util/app_exceptions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/exception/exception_widget.dart';

class SimulasiNilaiWidget extends StatefulWidget {
  const SimulasiNilaiWidget({Key? key}) : super(key: key);

  @override
  State<SimulasiNilaiWidget> createState() => _SimulasiNilaiWidgetState();
}

class _SimulasiNilaiWidgetState extends State<SimulasiNilaiWidget> {
  late final simulasiNilaiProvider = context.read<SimulasiNilaiProvider>();
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();
  late final String _noRegistrasi = _authProvider.userData!.noRegistrasi;
  late final String _idSekolahKelas = _authProvider.userData!.idSekolahKelas;
  String? pilihTO;
  final ScrollController scrollController = ScrollController();

  late final Future<List<NilaiModel>> _futureLoadNilai =
      context.read<SimulasiNilaiProvider>().loadNilai(
            noRegistrasi: _noRegistrasi,
            idSekolahKelas: _idSekolahKelas,
          );

  int? _selectedIndex;
  NilaiModel? _nilaiModel;
  bool? isFix;

  @override
  Widget build(BuildContext context) {
    _selectedIndex = context
        .select((SimulasiNilaiProvider provider) => provider.selectedIndex);
    _nilaiModel =
        context.select((SimulasiNilaiProvider provider) => provider.nilaiModel);
    isFix = context.select((SimulasiNilaiProvider provider) => provider.isFix);

    return FutureBuilder(
      future: _futureLoadNilai,
      builder: (context, nilaiSnapshot) {
        Widget basicEmpty = BasicEmpty(
          shrink: (context.dh < 600) ? !context.isMobile : false,
          imageUrl: 'ilustrasi_data_not_found.png'.illustration,
          title: 'Oops',
          subTitle: 'Nilai TO Tidak Ditemukan',
          emptyMessage: '${nilaiSnapshot.error}',
        );

        return nilaiSnapshot.connectionState == ConnectionState.done
            ? nilaiSnapshot.hasError
                ? ((context.isMobile || context.dh > 600)
                    ? basicEmpty
                    : SingleChildScrollView(child: basicEmpty))
                : nilaiSnapshot.hasData
                    ? SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            _buildPeriodePicker(nilaiSnapshot.data),
                            _buildDetailNilai(),
                          ],
                        ),
                      )
                    : const ExceptionWidget(
                        'Belum ada data untuk saat ini',
                        exceptionMessage: '',
                      )
            : loadingShimmer(context);
      },
    );
  }

  Widget loadingShimmer(BuildContext context) {
    return Column(
      children: [
        ShimmerWidget.rounded(
          width: context.dw,
          height: 50,
          borderRadius: BorderRadius.circular(24),
        ),
        const SizedBox(
          height: 10,
        ),
        ShimmerWidget.rounded(
          width: context.dw,
          height: 400,
          borderRadius: BorderRadius.circular(24),
        ),
      ],
    );
  }

  void _onButtonPressed(Map<String, dynamic> detailNilai) async {
    try {
      // CustomDialog.loadingDialog(context);

      await context
          .read<SimulasiNilaiProvider>()
          .saveNilai(
            noRegistrasi: _noRegistrasi,
            kodeTOB: _nilaiModel!.kodeTob,
            detailNilai: detailNilai,
          )
          .then((_) {
        gShowTopFlash(context, 'Data nilai berhasil disimpan',
            dialogType: DialogType.success);
        Navigator.pop(context, true);
      });
    } on NoConnectionException catch (_) {
      Navigator.pop(context, true);
      gShowTopFlash(context, _.toString());
    } on DataException catch (e) {
      Navigator.pop(context);
      gShowTopFlash(context, e.toString());
    } catch (e) {
      Navigator.pop(context);
      gShowTopFlash(context, e.toString());
    }
  }

  Widget _buildPeriodePicker(List<NilaiModel?>? listNilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                margin: EdgeInsets.only(right: context.dp(12)),
                decoration: BoxDecoration(
                    color: context.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(-1, -1),
                          blurRadius: 4,
                          spreadRadius: 1,
                          color: context.primaryColor.withOpacity(0.42)),
                      BoxShadow(
                          offset: const Offset(1, 1),
                          blurRadius: 4,
                          spreadRadius: 1,
                          color: context.primaryColor.withOpacity(0.42))
                    ]),
                child: Icon(
                  Icons.checklist_rounded,
                  size: context.dp(24),
                  color: context.background,
                ),
              ),
              horizontalTitleGap: 5,
              title: Text(
                'Pilih Tryout',
                style: context.text.labelLarge,
              ),
              subtitle: Text(
                listNilai![_selectedIndex!]!.tob,
                style: context.text.bodyMedium,
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
                                  setState(() {
                                    _selectedIndex = index;
                                    pilihTO = listNilai[_selectedIndex!]!.tob;
                                  });
                                  if (kDebugMode) {
                                    logger
                                        .log("_selectedIndex $_selectedIndex");
                                    logger.log(
                                        "listNilai[index]!.tob, ${listNilai[index]!.tob}");
                                    logger.log(
                                        "listNilai[index]!.detailNilai, ${listNilai[index]!.detailNilai}");
                                  }
                                  Navigator.of(context).pop(_selectedIndex);
                                  _onButtonPressed(
                                      listNilai[index]!.detailNilai);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      listNilai[index]!.tob,
                                      style: context.text.bodyLarge,
                                    ),
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
            setState(() {
              _selectedIndex = selectedType;
              pilihTO = listNilai[_selectedIndex!]!.tob;
              context
                  .read<SimulasiNilaiProvider>()
                  .setSelectedIndex(selectedType);
            });
          }
        },
      ),
    );
  }

  Widget _buildDetailNilai() {
    return Consumer<SimulasiNilaiProvider>(
      builder: (_, value, __) => Container(
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
                            nilai,
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
}
