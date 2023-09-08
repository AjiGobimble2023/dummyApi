import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/shared/builder/responsive_builder.dart';
import '../../../../../soal/entity/detail_jawaban.dart';

// ignore: must_be_immutable
class KategoriScoreAndChartWidget extends StatefulWidget {
  KategoriScoreAndChartWidget({
    Key? key,
    this.mapel,
    this.kodeSoal,
    this.listJawaban,
    this.kategori,
  }) : super(key: key);
  String? mapel;
  String? kodeSoal;
  List<DetailJawaban>? listJawaban;
  Map<String, dynamic>? kategori;

  @override
  State<KategoriScoreAndChartWidget> createState() =>
      _KategoriScoreAndChartWidgetState();
}

class _KategoriScoreAndChartWidgetState
    extends State<KategoriScoreAndChartWidget> {
  final Color? _benarColor = Palette.kSuccessSwatch[200];
  final Color? _salahColor = Palette.kPrimarySwatch[200];
  final Color? _benarTextColor = Palette.kSuccessSwatch[900];
  final Color? _salahTextColor = Palette.kPrimarySwatch[900];

  int? touchedIndex;
  int benar = 0;
  int salah = 0;
  int jumlah = 0;
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.listJawaban!.length; i++) {
      if (widget.listJawaban![i].jawabanSiswa ==
          widget.listJawaban![i].kunciJawaban) {
        benar++;
      } else {
        salah++;
      }
      jumlah = widget.listJawaban!.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.isMobile ? context.dp(12) : context.dp(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          buildKuisInfo(context),
          const Divider(
            height: 0,
          ),
          buildCategoryAndScore(context),
          buildKuisPieChart(context)
        ],
      ),
    );
  }

  Container buildCategoryAndScore(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          top: context.isMobile ? context.dp(12) : context.dp(6),
        ),
        width: context.dw,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Kategori : ",
                  style: context.text.titleMedium,
                ),
                Text(
                  widget.kategori!['status'].toString(),
                  style: context.text.titleMedium
                      ?.copyWith(color: widget.kategori!['warna']),
                )
              ],
            ),
            Visibility(
              visible: context.isMobile,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(300),
                  color: context.secondaryColor,
                ),
                child: Text("Skor : ${widget.kategori!['nilai']}",
                    style: context.text.labelLarge),
              ),
            ),
          ],
        ));
  }

  ListTile buildKuisInfo(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(
        bottom: context.isMobile ? context.dp(12) : context.dp(6),
      ),
      leading: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.tertiaryColor)),
        child: Text(
          widget.kodeSoal!,
          style:
              context.text.labelLarge?.copyWith(color: context.tertiaryColor),
        ),
      ),
      title: Text(
        'Mata Pelajaran',
        style: context.text.labelLarge?.copyWith(color: context.hintColor),
      ),
      subtitle: Text(widget.mapel!, style: context.text.labelLarge),
    );
  }

  ResponsiveBuilder buildKuisPieChart(BuildContext context) {
    return ResponsiveBuilder(
      mobile: Column(
        children: [
          SizedBox(
            height: 320,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 60,
                sections: showingSections(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _benarColor,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      color: _benarTextColor,
                    ),
                  ),
                  Text('Benar : $benar', style: context.text.labelLarge)
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _salahColor,
                    ),
                    child: Icon(
                      Icons.cancel_outlined,
                      color: _salahTextColor,
                    ),
                  ),
                  Text('Salah : $salah', style: context.text.labelLarge)
                ],
              )
            ],
          ),
        ],
      ),
      tablet: Row(
        children: [
          SizedBox(
            height: 320,
            width: ((context.dw - context.dp(132)) / 2) - context.pd,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 60,
                sections: showingSections(),
              ),
            ),
          ),
          SizedBox(
            height: 320,
            width: ((context.dw - context.dp(132)) / 2) - context.pd,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(300),
                    color: context.secondaryColor,
                  ),
                  child: Text("Skor : ${widget.kategori!['nilai']}",
                      style: context.text.labelLarge),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _benarColor,
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        color: _benarTextColor,
                        size: context.dp(10),
                      ),
                    ),
                    Text('Benar : $benar', style: context.text.labelLarge)
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _salahColor,
                      ),
                      child: Icon(
                        Icons.cancel_outlined,
                        color: _salahTextColor,
                        size: context.dp(10),
                      ),
                    ),
                    Text('Salah : $salah', style: context.text.labelLarge)
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    int total = jumlah;
    double benarPercentage = 0;
    double salahPercentage = 0;

    if (total > 0) {
      benarPercentage = benar / total * 100;
      salahPercentage = salah / total * 100;
    }
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 100.0 : 80.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: _benarColor,
            value: benarPercentage,
            title: '${benarPercentage.round()}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: _benarTextColor,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: _salahColor,
            value: salahPercentage,
            title: '${salahPercentage.round()}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: _salahTextColor,
              shadows: shadows,
            ),
          );

        default:
          throw Exception('Terjadi Kesalahan pada KuisPieChartWidget');
      }
    });
  }
}
