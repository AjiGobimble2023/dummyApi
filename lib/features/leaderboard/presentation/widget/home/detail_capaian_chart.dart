import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../model/capaian_detail_score.dart';
import '../../../../../core/config/theme.dart';
import '../../../../../core/config/extensions.dart';

enum BSK { benar, salah, kosong }

class DetailCapaianChart extends StatefulWidget {
  final CapaianDetailScore capaianDetail;

  const DetailCapaianChart({Key? key, required this.capaianDetail})
      : super(key: key);

  @override
  State<DetailCapaianChart> createState() => _DetailCapaianChartState();
}

class _DetailCapaianChartState extends State<DetailCapaianChart> {
  final Color? _benarColor = Palette.kSuccessSwatch[200];
  final Color? _salahColor = Palette.kPrimarySwatch[200];
  final Color _kosongColor = Colors.black38;
  final Color? _benarTextColor = Palette.kSuccessSwatch[900];
  final Color? _salahTextColor = Palette.kPrimarySwatch[900];
  final Color _kosongTextColor = Colors.black54;
  // Radius
  late final double _centerSpaceRadius = (context.isMobile) ? 40.0 : 50.0;
  late final double _chartRadius = (context.isMobile) ? 50.0 : 82.0;
  late final double _chartRadiusTouched = (context.isMobile) ? 60.0 : 100.0;
  final double _fontSize = 16.0;
  final double _fontSizeTouched = 25.0;

  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    int total = widget.capaianDetail.total;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Row(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ((total <= 0))
                  ? Center(
                      child: Text(
                        'Belum ada Soal ${widget.capaianDetail.label}\n'
                        'yang sudah dikerjakan',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: _centerSpaceRadius,
                        sections: showingSections(),
                      ),
                    ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildIndicator(
                  label: 'Benar:\n ${widget.capaianDetail.benar}',
                  mode: BSK.benar),
              const SizedBox(height: 4),
              _buildIndicator(
                  label: 'Salah:\n ${widget.capaianDetail.salah}',
                  mode: BSK.salah),
              if ((widget.capaianDetail.kosong ?? 0) > 0)
                const SizedBox(height: 4),
              if ((widget.capaianDetail.kosong ?? 0) > 0)
                _buildIndicator(
                    label: 'Kosong:\n ${widget.capaianDetail.kosong}',
                    mode: BSK.kosong),
              const SizedBox(height: 18),
            ],
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildIndicator({
    required String label,
    required BSK mode,
  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (mode == BSK.benar)
                  ? _benarColor
                  : (mode == BSK.salah)
                      ? _salahColor
                      : _kosongColor,
            ),
            child: Icon(
              (mode == BSK.benar)
                  ? Icons.check_circle_outline_rounded
                  : (mode == BSK.benar)
                      ? Icons.cancel_outlined
                      : Icons.do_disturb_on_outlined,
              color: (mode == BSK.benar)
                  ? _benarTextColor
                  : (mode == BSK.salah)
                      ? _salahTextColor
                      : _kosongTextColor,
            ),
          ),
          Text(
            label,
            style: context.text.labelLarge,
          )
        ],
      );

  List<PieChartSectionData> showingSections() {
    int total = widget.capaianDetail.total;
    double benarPercentage = 0;
    double salahPercentage = 0;
    double kosongPercentage = 0;

    if (total > 0) {
      benarPercentage = widget.capaianDetail.benar / total * 100;
      salahPercentage = widget.capaianDetail.salah / total * 100;
      kosongPercentage = (widget.capaianDetail.kosong ?? 0) / total * 100;
    }

    return List.generate(
      ((widget.capaianDetail.kosong ?? 0) > 0) ? 3 : 2,
      (i) {
        final isTouched = i == _touchedIndex;
        final fontSize = isTouched ? _fontSizeTouched : _fontSize;
        double radius = isTouched ? _chartRadiusTouched : _chartRadius;

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
            color: _kosongColor,
            value: kosongPercentage,
            title: '${kosongPercentage.round()}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: _kosongTextColor,
            ),
          );
        }
      },
    );
  }
}
