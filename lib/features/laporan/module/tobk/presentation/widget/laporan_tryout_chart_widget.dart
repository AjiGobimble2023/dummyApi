import 'package:flutter/material.dart';

import '../../model/laporan_tryout_tob_model.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/chart/line_chart_widget.dart';

class LaporanTryoutChartWidget extends StatefulWidget {
  const LaporanTryoutChartWidget({
    super.key,
    this.jenisTO,
    this.listTryout,
  });

  /// [jenisTO] variabel yang berisi data jenis TO yang dipilih
  final String? jenisTO;

  /// [listTryout] adalah variabel yang menampung data laporan TO yang dipilih
  /// list ini berisi data (kode, nama, penilaian, link, pilihan, isExists, tanggalAkhir)
  final List<LaporanTryoutTobModel>? listTryout;

  @override
  State<LaporanTryoutChartWidget> createState() =>
      _LaporanTryoutChartWidgetState();
}

class _LaporanTryoutChartWidgetState extends State<LaporanTryoutChartWidget> {
  /// Kumpulan variabel untuk keperluan line chart TO
  double? maxValue, interval;
  List<int>? nilaiChart;
  List<int> pg = [];

  /// Kumpulan variabel untuk keperluan data kampus impian
  bool? pilihan, pilihanSwitch = true;
  int selectedPilihan = 0;

  @override
  Widget build(BuildContext context) {
    /// Inisilisasi value untuk variabel line chart TO dan data kampus impian
    /// berdasarkan jenis TO
    switch (widget.jenisTO) {
      case "UTBK":
        maxValue = 1000.0;
        interval = 200.0;
        pilihan = true;
        nilaiChart = widget.listTryout!
            .take(5)
            .map((tryout) =>
                double.parse(tryout.pilihan[selectedPilihan].nilai).toInt())
            .toList();
        pg = widget.listTryout!
            .take(5)
            .map((tryout) =>
                double.parse(tryout.pilihan[selectedPilihan].pg).toInt())
            .toList();
        break;
      case "US":
        // maxValue = 500.0;
        maxValue = 100.0;
        interval = 20.0;
        pilihan = false;
        nilaiChart = widget.listTryout!
            .take(5)
            .map((tryout) => double.parse(tryout.pilihan[0].nilai).toInt())
            .toList();
        break;
      case "ANBK":
        maxValue = 500.0;
        interval = 50.0;
        pilihan = false;
        nilaiChart = widget.listTryout!
            .take(5)
            .map((tryout) => double.parse(tryout.pilihan[0].nilai).toInt())
            .toList();
        break;
      case "STAN":
        maxValue = 500.0;
        interval = 50.0;
        pilihan = false;
        nilaiChart = widget.listTryout!
            .take(5)
            .map((tryout) => double.parse(tryout.pilihan[0].nilai).toInt())
            .toList();
        break;
      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: <Widget>[
          buildPilihanPTN(context),
          buildLineChart(context),
        ],
      ),
    );
  }

  /// [buildLineChart] widget untuk menampilkan line chart Nilai TO
  Column buildLineChart(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 10),
          width: context.dw,
          height: (context.isMobile) ? context.dh * 0.3 : context.dh * 0.5,
          child: LineChartUTBK(
            values: nilaiChart,
            pg: pg,
            maxValue: maxValue,
            interval: interval,
          ),
        ),
        if (pilihan!)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Chip(
                    label: Text(
                      'Target',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.onSecondary),
                    ),
                    backgroundColor: context.secondaryColor),
                Chip(
                    label: Text(
                      'Skor',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.onPrimary),
                    ),
                    backgroundColor: context.primaryColor),
              ],
            ),
          ),
      ],
    );
  }

  /// [buildPilihanPTN] widget untuk menampilkan data kampus impian pilihan 1 dan 2
  Visibility buildPilihanPTN(BuildContext context) {
    return Visibility(
      visible: (widget.jenisTO == "UTBK"),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (selectedPilihan == 0) {
                  selectedPilihan = 1;
                } else {
                  selectedPilihan = 0;
                }
              });
            },
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.tertiaryColor)),
                child: Text(
                  widget.listTryout![0].pilihan[selectedPilihan].namakelompok,
                  style: context.text.labelLarge
                      ?.copyWith(color: context.tertiaryColor),
                ),
              ),
              title: Text(widget.listTryout![0].pilihan[selectedPilihan].ptn,
                  style: context.text.labelLarge
                      ?.copyWith(color: context.hintColor)),
              subtitle: Text(
                  widget.listTryout![0].pilihan[selectedPilihan].jurusan,
                  style: context.text.titleMedium),
              trailing: const Icon(Icons.change_circle_outlined),
            ),
          ),
          const Divider(height: 18, color: Colors.black54),
        ],
      ),
    );
  }
}
