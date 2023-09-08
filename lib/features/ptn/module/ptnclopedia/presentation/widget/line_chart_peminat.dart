import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/config/extensions.dart';

/// [LineChartPeminat] merupakan widget yang menampilkan informasi tentang
/// jumlah peminat dan daya tampung dari PTN-Clopedia.
class LineChartPeminat extends StatefulWidget {
  final List<dynamic> peminat;
  final List<dynamic> dayaTampung;

  const LineChartPeminat({
    super.key,
    required this.peminat,
    required this.dayaTampung,
  });

  @override
  State<LineChartPeminat> createState() => _LineChartPeminatState();
}

class _LineChartPeminatState extends State<LineChartPeminat> {
  late final List<Color> gradientPeminat = [
    context.secondaryColor,
    context.secondaryContainer,
  ];

  late final List<Color> gradientDayaTampung = [
    context.primaryColor,
    context.primaryContainer,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.dp(24),
        bottom: context.dp(18),
        right: context.dp(24),
      ),
      child: AspectRatio(
        aspectRatio: 1.70,
        child: LineChart(mainData()),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${widget.dayaTampung[value.toInt()]['tahun']}'),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: (context.isMobile) ? 42 : 64,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: context.disableColor),
          bottom: BorderSide(color: context.disableColor),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: context.secondaryContainer,
          fitInsideHorizontally: true,
          tooltipRoundedRadius: 14,
          maxContentWidth: context.dw * 0.6,
          getTooltipItems: (touchedSpots) => touchedSpots
              .map<LineTooltipItem>(
                (barSpot) => LineTooltipItem(
                  (barSpot.barIndex == 0)
                      ? 'Peminat: ${barSpot.y.toInt()} Orang'
                      : 'Daya Tampung: ${barSpot.y.toInt()} Orang',
                  context.text.bodyMedium!,
                  textAlign: TextAlign.left,
                ),
              )
              .toList(),
        ),
      ),
      minY: 0,
      minX: 0,
      maxX: (widget.peminat.length - 1).toDouble(),
      lineBarsData: [_lineChartPeminat(), _lineChartDayaTampung()],
    );
  }

  LineChartBarData _lineChartPeminat() {
    return LineChartBarData(
      spots: List.generate(
        widget.peminat.length,
        (index) => FlSpot(
          index.toDouble(),
          widget.peminat[index]['jml'].toDouble(),
        ),
      ),
      isCurved: true,
      gradient: LinearGradient(colors: gradientPeminat),
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
          colors:
              gradientPeminat.map((color) => color.withOpacity(0.3)).toList(),
        ),
      ),
    );
  }

  LineChartBarData _lineChartDayaTampung() {
    return LineChartBarData(
      spots: List.generate(
        widget.dayaTampung.length,
        (index) => FlSpot(
          index.toDouble(),
          widget.dayaTampung[index]['jml'].toDouble(),
        ),
      ),
      isCurved: true,
      gradient: LinearGradient(colors: gradientDayaTampung),
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
          colors: gradientDayaTampung
              .map((color) => color.withOpacity(0.3))
              .toList(),
        ),
      ),
    );
  }
}
