import 'dart:developer' as logger show log;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/extensions.dart';

class LineChartUTBK extends StatefulWidget {
  const LineChartUTBK({
    Key? key,
    required this.values,
    this.pg,
    this.interval,
    this.maxValue,
  }) : super(key: key);

  /// [values] merupakan variabel list yang menampung data nilai TO siswa
  final List<int>? values;

  /// [pg] merupakan variabel list yang menampung data nilai
  /// passing grade kampus impian pilihan sisea
  final List<int>? pg;

  /// [interval] merupakan interval nilai pada line chart
  final double? interval;

  /// [maxValue] merupakan nilai max pada line chart
  final double? maxValue;

  @override
  State<LineChartUTBK> createState() => _LineChartUTBKState();
}

class _LineChartUTBKState extends State<LineChartUTBK> {
  /// [gradientColors] untuk keperluan style Score/Nilai Siswa
  late final List<Color> gradientColors = [
    context.primaryColor,
    context.primaryContainer,
  ];

  /// [gradientColors] untuk keperluan style Passing Grade
  late final List<Color> gradientColorsPg = [
    context.secondaryColor,
    context.secondaryContainer,
  ];

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      logger.log("values ${widget.values}");
      logger.log("pg ${widget.pg}");
      for (int i = 0; i < widget.values!.length; i++) {
        logger.log("values ${widget.values![i]} $i");
      }
    }

    return LineChart(
      data,
    );
  }

  /// Inisialisasi nilai [data] Widget untuk menampilkan LineChart
  LineChartData get data => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 1,
        maxX: 5,
        maxY: widget.maxValue ?? 100,
        minY: 0,
      );

  /// [lineTouchData] widget untuk menampilkan keterangan nilai siswa saat data nilai di klik
  LineTouchData get lineTouchData => LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipPadding: const EdgeInsets.all(8),
        tooltipBgColor: const Color(0xffffcc29).withOpacity(0.5),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            return LineTooltipItem(
                '${(touchedSpot.barIndex == 1) ? 'Skor' : 'Target'} : ${touchedSpot.y.round()}',
                const TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.left);
          }).toList();
        },
      ));

  /// [titlesData] widget untuk menampikan data nilai pada sumbu X dan dan sumbu Y di line Chart
  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: (context.isMobile) ? 30 : 60,
            interval: 1,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: widget.interval ?? 20,
            reservedSize: (context.isMobile) ? 40 : 60,
          ),
        ),
      );

  List<LineChartBarData> get lineBarsData => [
        lineChartScore,
        lineChartPg,
      ];

  /// [gridData] widget untuk menampilkan grid pada lineChart
  FlGridData get gridData => const FlGridData(
        show: true,
      );

  /// [borderData] widget untuk menampilkan border pada lineChart
  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: context.disableColor),
          bottom: BorderSide(color: context.disableColor),
        ),
      );

  /// [lineChartScore] widget untuk menampilkan data nilai siswa pada LineChart
  LineChartBarData get lineChartScore => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: gradientColorsPg),
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
            strokeWidth: 1,
            radius: 6,
            strokeColor: Colors.black38,
            color: context.secondaryColor,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: gradientColorsPg
                .map((color) => color.withOpacity(0.3))
                .toList(),
          ),
        ),
        spots: [
          for (int i = 0; i < widget.pg!.length; i++)
            FlSpot(i.toDouble() + 1, widget.pg![i].toDouble()),
        ],
      );

  /// [lineChartPg] widget untuk menampilkan data nilai passing grade kampus impian pada LineChart
  LineChartBarData get lineChartPg => LineChartBarData(
        preventCurveOverShooting: true,
        isCurved: true,
        gradient: LinearGradient(colors: gradientColors),
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
            strokeWidth: 1,
            radius: 6,
            strokeColor: context.onPrimary,
            color: context.primaryColor,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
        spots: [
          for (int i = 0; i < widget.values!.length; i++)
            FlSpot(i.toDouble() + 1, widget.values![i].toDouble()),
        ],
      );
}
