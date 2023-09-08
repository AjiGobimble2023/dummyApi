import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../../core/config/extensions.dart';

import '../../../../../../core/config/theme.dart';
import '../../model/laporan_tryout_nilai_model.dart';

class DetailNilaiChart extends StatefulWidget {
  final LaporanTryoutNilaiModel listJawaban;
  const DetailNilaiChart({Key? key, required this.listJawaban})
      : super(key: key);

  @override
  State<DetailNilaiChart> createState() => _DetailNilaiChartState();
}

class _DetailNilaiChartState extends State<DetailNilaiChart> {
  final Color? _benarColor = Palette.kSuccessSwatch[200];
  final Color? _salahColor = Palette.kPrimarySwatch[200];
  final Color? _benarTextColor = Palette.kSuccessSwatch[900];
  final Color? _salahTextColor = Palette.kPrimarySwatch[900];

  int _touchedIndex = -1;
  int benar = 0;
  int salah = 0;
  int kosong = 0;
  int jumlah = 0;

  @override
  void initState() {
    prepareData();
    super.initState();
  }

  prepareData() {
    benar += widget.listJawaban.benar;
    salah += widget.listJawaban.salah;
    kosong += widget.listJawaban.kosong;
    jumlah = benar + salah + kosong;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Row(
        children: <Widget>[
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                startDegreeOffset: (context.isMobile) ? 0 : 90,
                centerSpaceRadius: 30,
                sections: showingSections(),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildIndicator(
                  label: 'Benar:\n $benar', isBenar: true, isKosong: false),
              const SizedBox(height: 4),
              _buildIndicator(
                  label: 'Salah:\n $salah', isBenar: false, isKosong: false),
              const SizedBox(height: 4),
              _buildIndicator(
                  label: 'Kosong:\n $kosong', isBenar: false, isKosong: true),
            ],
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildIndicator(
          {required String label,
          required bool isBenar,
          required bool isKosong}) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isBenar)
                  ? _benarColor
                  : (isKosong)
                      ? context.hintColor
                      : _salahColor,
            ),
            child: Icon(
              (isBenar)
                  ? Icons.check_circle_outline_rounded
                  : (isKosong)
                      ? Icons.remove_circle_outline_outlined
                      : Icons.cancel_outlined,
              color: (isBenar)
                  ? _benarTextColor
                  : (isKosong)
                      ? context.background
                      : _salahTextColor,
            ),
          ),
          Text(label, style: context.text.labelLarge)
        ],
      );

  List<PieChartSectionData> showingSections() {
    int total = jumlah;

    double benarPercentage = 0;
    double salahPercentage = 0;
    double kosongPercentage = 0;

    if (total > 0) {
      benarPercentage = benar / total * 100;
      salahPercentage = salah / total * 100;
      kosongPercentage = kosong / total * 100;
    }

    return List.generate(
      3,
      (i) {
        final isTouched = i == _touchedIndex;
        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 60.0 : 50.0;

        if (i == 0) {
          return PieChartSectionData(
            color: _benarColor,
            value: benarPercentage,
            title: '${benarPercentage.round()}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: _benarTextColor,
            ),
          );
        } else if (i == 1) {
          return PieChartSectionData(
            color: _salahColor,
            value: salahPercentage,
            title: '${salahPercentage.round()}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: _salahTextColor,
            ),
          );
        } else {
          return PieChartSectionData(
            color: context.hintColor,
            value: kosongPercentage,
            title: '${kosongPercentage.round()}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: context.background,
            ),
          );
        }
      },
    );
  }
}
