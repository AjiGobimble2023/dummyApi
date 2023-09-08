import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'line_chart_peminat.dart';
import 'ptn_search_delegate.dart';
import 'ptn_jurusan_search_delegate.dart';
import '../provider/ptn_provider.dart';
import '../../entity/ptn.dart';
import '../../entity/jurusan.dart';
import '../../entity/kampus_impian.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/util/app_exceptions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';

class PtnClopediaWidget extends StatefulWidget {
  final int? pilihanKe;
  final KampusImpian? kampusPilihan;
  final EdgeInsetsGeometry? padding;
  final bool isLandscape;
  final bool isSimulasi;

  const PtnClopediaWidget({
    super.key,
    this.pilihanKe,
    this.kampusPilihan,
    this.padding,
    this.isLandscape = false,
    this.isSimulasi = false,
  });

  @override
  State<PtnClopediaWidget> createState() => _PtnClopediaWidgetState();
}

class _PtnClopediaWidgetState extends State<PtnClopediaWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _getDetailJurusan(),
      builder: (_, snapshot) {
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (isLoading) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text(
                  'Sedang menyiapkan data\ndetail jurusan...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: widget.padding ??
                EdgeInsets.only(
                  top: min(38, context.dp(20)),
                  left: min(28, context.dp(16)),
                  right: min(28, context.dp(16)),
                  bottom: (widget.isLandscape) ? 48 : context.dp(32),
                ),
            child: Selector<PtnProvider, PTN?>(
              selector: (_, ptn) => ptn.selectedPTN,
              builder: (_, selectedPTN, emptyPTN) {
                return Selector<PtnProvider, Jurusan?>(
                  selector: (_, ptn) => ptn.selectedJurusan,
                  builder: (context, selectedJurusan, emptyJurusan) {
                    if (kDebugMode) {
                      logger.log(
                          'PTN_CLOPEDIA-Selector: Selected Jurusan >> $selectedJurusan\n'
                          'Variable >> ${widget.kampusPilihan}');
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.isLandscape)
                          Row(
                            children: List<Expanded>.generate(
                              _buildPickerButton(selectedPTN, selectedJurusan)
                                  .length,
                              (index) => Expanded(
                                child: _buildPickerButton(
                                    selectedPTN, selectedJurusan)[index],
                              ),
                            ),
                          ),
                        if (!widget.isLandscape)
                          ..._buildPickerButton(selectedPTN, selectedJurusan),
                        if (selectedPTN == null &&
                            widget.kampusPilihan == null &&
                            selectedJurusan == null)
                          emptyPTN!,
                        if ((selectedPTN != null ||
                                widget.kampusPilihan != null) &&
                            selectedJurusan == null)
                          emptyJurusan!,
                        if (!widget.isLandscape &&
                            (selectedPTN != null ||
                                widget.kampusPilihan != null) &&
                            selectedJurusan != null &&
                            selectedJurusan.namaJurusan.isNotEmpty)
                          ..._displayInformasi(
                              selectedPTN?.namaPTN ??
                                  widget.kampusPilihan!.namaPTN,
                              selectedJurusan),
                        if (widget.isLandscape &&
                            (selectedPTN != null ||
                                widget.kampusPilihan != null) &&
                            selectedJurusan != null &&
                            selectedJurusan.namaJurusan.isNotEmpty)
                          ..._displayInformationHeader(
                              selectedPTN?.namaPTN ??
                                  widget.kampusPilihan!.namaPTN,
                              selectedJurusan),
                        if (widget.isLandscape &&
                            (selectedPTN != null ||
                                widget.kampusPilihan != null) &&
                            selectedJurusan != null &&
                            selectedJurusan.namaJurusan.isNotEmpty)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: _displayInformasi(
                                        selectedPTN?.namaPTN ??
                                            widget.kampusPilihan!.namaPTN,
                                        selectedJurusan),
                                  ),
                                ),
                                const VerticalDivider(width: 32),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: _displayInformasiDeskripsi(
                                        selectedJurusan),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                  child: BasicEmpty(
                    shrink: true,
                    isLandscape: widget.isLandscape,
                    imageUrl: 'ilustrasi_sbmptn.png'.illustration,
                    title:
                        (widget.isSimulasi) ? 'Simulasi SNBT' : 'PTN-Clopedia',
                    subTitle: 'Mau cari info jurusan apa Sobat?',
                    emptyMessage: 'Pilih Jurusan terlebih dahulu ya Sobat',
                  ),
                );
              },
              child: BasicEmpty(
                shrink: true,
                isLandscape: widget.isLandscape,
                imageUrl: 'ilustrasi_sbmptn.png'.illustration,
                title: (widget.isSimulasi) ? 'Simulasi SNBT' : 'PTN-Clopedia',
                subTitle: 'Mau cari info jurusan apa Sobat?',
                emptyMessage: 'Pilih PTN dan Jurusan terlebih dahulu ya Sobat',
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _getDetailJurusan() async {
    if (widget.kampusPilihan != null) {
      await context
          .read<PtnProvider>()
          .getDetailJurusan(idJurusan: widget.kampusPilihan!.idJurusan);
    }
  }

  Future<void> _onClickPilihJurusan(PTN? selectedPTN) async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    try {
      if (selectedPTN == null && widget.kampusPilihan == null) {
        throw DataException(message: 'Silahkan pilih PTN terlebih dahulu!');
      }

      List<Jurusan> listJurusan =
          await context.read<PtnProvider>().loadJurusanList(
                idPTN: selectedPTN?.idPTN ?? widget.kampusPilihan!.idPTN,
              );

      completer.complete();

      Jurusan? pilihanJurusan = await showSearch<Jurusan?>(
        context: context,
        delegate: JurusanSearchDelegate(listJurusan),
      );

      if (kDebugMode) {
        logger.log(
            'PTN_CLOPEDIA-OnClickPilihJurusan: Selected >> $pilihanJurusan');
      }

      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted && pilihanJurusan != null) {
        bool setValue = true;
        if (widget.kampusPilihan != null) {
          setValue =
              pilihanJurusan.idJurusan != widget.kampusPilihan!.idJurusan;
        }
        if (kDebugMode) {
          logger.log(
              'PTN_CLOPEDIA-OnClickPilihJurusan: $setValue >> ${pilihanJurusan.idJurusan} || ${widget.kampusPilihan?.idJurusan}');
        }
        if (setValue) {
          context.read<PtnProvider>().selectedJurusan = pilihanJurusan;
        }
      }
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-OnClickPilihJurusan: $e');
      }

      completer.complete();
      gShowTopFlash(context, gPesanErrorKoneksi);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-OnClickPilihJurusan: $e');
      }

      completer.complete();
      gShowTopFlash(context, e.toString());
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-OnClickPilihJurusan: $e');
      }

      completer.complete();
      gShowTopFlash(context, gPesanError);
    }
  }

  Future<void> _onClickPilihPTN() async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    try {
      List<PTN> daftarPTN =
          await context.read<PtnProvider>().loadListUniversitas();

      completer.complete();

      PTN? pilihanPTN = await showSearch<PTN?>(
          context: context, delegate: PTNSearchDelegate(daftarPTN));

      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted && pilihanPTN != null) {
        bool setValue = true;
        if (widget.kampusPilihan != null) {
          setValue = pilihanPTN.idPTN != widget.kampusPilihan!.idPTN;
        }
        if (setValue) {
          context.read<PtnProvider>().selectedPTN = pilihanPTN;
        }
      }
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-OnClickPilihPTN: $e');
      }

      completer.complete();
      gShowTopFlash(context, gPesanErrorKoneksi);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-OnClickPilihPTN: $e');
      }

      completer.complete();
      gShowTopFlash(context, e.toString());
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-OnClickPilihPTN: $e');
      }

      completer.complete();
      gShowTopFlash(context, gPesanError);
    }
  }

  List<Widget> _buildPickerButton(PTN? selectedPTN, Jurusan? selectedJurusan) =>
      [
        _buildOptionButton(
            title: 'Pilihan PTN',
            subTitle: ((selectedPTN?.namaPTN.isEmpty ?? true) &&
                    widget.kampusPilihan == null)
                ? 'Pilih Perguruan Tinggi Negeri'
                : (selectedPTN != null && selectedPTN.namaPTN.isNotEmpty)
                    ? selectedPTN.namaPTN
                    : widget.kampusPilihan?.namaPTN ??
                        'Pilih Perguruan Tinggi Negeri',
            margin: (widget.isLandscape)
                ? const EdgeInsets.only(right: 16, bottom: 32)
                : null,
            onClick: _onClickPilihPTN),
        _buildOptionButton(
            title: 'Pilihan Jurusan',
            subTitle: ((selectedJurusan?.namaJurusan.isEmpty ?? true) &&
                    widget.kampusPilihan == null)
                ? 'Pilih Jurusan'
                : (selectedJurusan != null &&
                        selectedJurusan.namaJurusan.isNotEmpty)
                    ? selectedJurusan.namaJurusan
                    : widget.kampusPilihan?.namaJurusan ?? 'Pilih Jurusan',
            margin: (widget.isLandscape)
                ? const EdgeInsets.only(left: 16, bottom: 32)
                : EdgeInsets.only(bottom: min(28, context.dp(24))),
            onClick: () async => await _onClickPilihJurusan(selectedPTN)),
      ];

  Widget _buildOptionButton({
    required String title,
    required String subTitle,
    required VoidCallback onClick,
    EdgeInsetsGeometry? margin,
  }) =>
      Container(
        margin: margin ?? EdgeInsets.only(bottom: min(16, context.dp(12))),
        decoration: BoxDecoration(
            borderRadius: gDefaultShimmerBorderRadius,
            border: Border.all(color: context.disableColor)),
        child: ListTile(
          onTap: onClick,
          tileColor: Colors.transparent,
          trailing: const Icon(Icons.edit),
          title: Text(title, style: context.text.bodyMedium),
          subtitle: Text(
            subTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );

  Row _buildTitle(BuildContext context, String title,
          {bool isSubTitle = false}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style:
                isSubTitle ? context.text.titleMedium : context.text.titleLarge,
          ),
          const Expanded(
            child: Divider(
                thickness: 1, indent: 8, endIndent: 8, color: Colors.black26),
          ),
        ],
      );

  List<Widget> _buildItem(String title, String isi) => [
        SizedBox(height: context.dp(20)),
        _buildTitle(context, title, isSubTitle: true),
        SizedBox(height: context.dp(12)),
        Padding(
          padding: EdgeInsets.only(left: context.dp(12)),
          child: Text(
            isi,
            style: context.text.bodyMedium?.copyWith(
              color: context.onBackground.withOpacity(0.76),
            ),
          ),
        ),
      ];

  List<Widget> _displayInformationHeader(
    String namaPTN,
    Jurusan selectedJurusan,
  ) =>
      [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.tertiaryColor)),
            child: Text(
              selectedJurusan.kelompok,
              style: context.text.labelLarge
                  ?.copyWith(color: context.tertiaryColor),
            ),
          ),
          title: Text(namaPTN,
              style:
                  context.text.labelLarge?.copyWith(color: context.hintColor)),
          subtitle: Text(selectedJurusan.namaJurusan,
              style: context.text.titleMedium),
        ),
        const Divider(height: 18, color: Colors.black54),
        Row(
          children: [
            Text('Lintas Jurusan: ', style: context.text.labelMedium),
            Icon(
              (selectedJurusan.lintas)
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              color: (selectedJurusan.lintas)
                  ? Palette.kSuccessSwatch
                  : context.errorColor,
            )
          ],
        ),
      ];

  List<Widget> _displayInformasiDeskripsi(
    Jurusan selectedJurusan,
  ) =>
      [
        // if (widget.isLandscape) const SizedBox(height: 120),
        if (selectedJurusan.deskripsi != null)
          ..._buildItem('Deskripsi Jurusan', selectedJurusan.deskripsi!),
        if (selectedJurusan.lapanganPekerjaan != null)
          ..._buildItem('Lapangan Kerja', selectedJurusan.lapanganPekerjaan!),
      ];

  List<Widget> _displayInformasi(
    String namaPTN,
    Jurusan selectedJurusan,
  ) =>
      [
        if (!widget.isLandscape)
          ..._displayInformationHeader(namaPTN, selectedJurusan),
        if (selectedJurusan.peminat.isNotEmpty)
          LineChartPeminat(
            peminat: selectedJurusan.peminat,
            dayaTampung: selectedJurusan.tampung,
          ),
        if (selectedJurusan.peminat.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Chip(
                  label: Text(
                    'Jumlah Peminat',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.onSecondary),
                  ),
                  backgroundColor: context.secondaryColor),
              Chip(
                  label: Text(
                    'Daya Tampung',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.onPrimary),
                  ),
                  backgroundColor: context.primaryColor),
            ],
          ),
        if (!widget.isLandscape) ..._displayInformasiDeskripsi(selectedJurusan),
      ];
}
