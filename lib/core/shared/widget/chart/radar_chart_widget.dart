import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

class RadarChartWidget extends StatelessWidget {
  final List<List<int>> values;
  final List<String>? lables;
  final List<Color>? colors;
  final List<int>? ticks;

  const RadarChartWidget({
    super.key,
    required this.values,
    this.lables,
    this.colors,
    this.ticks,
  });

  @override
  Widget build(BuildContext context) {
    return RadarChart(
      outlineColor: Colors.blue,
      axisColor: Colors.blue,
      data: values,
      features: lables!,
      ticks: ticks!,
      graphColors: colors!,
      sides: lables!.length,
    );
  }
}
