part of 'leaderboard_home_widget.dart';

class GrafikBarChart extends StatefulWidget {
  const GrafikBarChart({Key? key}) : super(key: key);

  @override
  State<GrafikBarChart> createState() => _GrafikBarChartState();
}

class _GrafikBarChartState extends State<GrafikBarChart> {
  late final CapaianProvider _capaianProvider =
      context.watch<CapaianProvider>();

  late final Color _barColor = context.primaryColor;
  final Color _touchedBarColor = Palette.kPrimarySwatch[700]!;
  late final Color _barBackgroundColor = context.primaryContainer;
  final Duration _animDuration = const Duration(milliseconds: 250);

  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: (context.isMobile) ? 12 / 8 : 16 / 9,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: max<double>(
            context.dw -
                ((context.isMobile) ? context.dp(72) : context.dp(182)),
            _capaianProvider.hasilPengerjaanSoal.length *
                ((context.isMobile) ? context.dp(29) : context.dp(15)),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              minY: 0,
              titlesData: _buildTitlesData(context),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barTouchData: _buildBarTouchData(context),
              // TODO: Ganti dengan data yang telah diambil dari API.
              barGroups: List<BarChartGroupData>.generate(
                _capaianProvider.hasilPengerjaanSoal.length,
                (indexMapelCapaian) {
                  PengerjaanSoal data =
                      _capaianProvider.hasilPengerjaanSoal[indexMapelCapaian];

                  double nilai = (_capaianProvider.filterNilai ==
                          FilterNilai.mingguan)
                      ? data.pengerjaanMingguan.toDouble()
                      : (_capaianProvider.filterNilai == FilterNilai.bulanan)
                          ? data.pengerjaanBulanan.toDouble()
                          : data.pengerjaanHarian.toDouble();

                  double target = (_capaianProvider.filterNilai ==
                          FilterNilai.mingguan)
                      ? data.targetMingguan.toDouble()
                      : (_capaianProvider.filterNilai == FilterNilai.bulanan)
                          ? data.targetBulanan.toDouble()
                          : data.targetHarian.toDouble();

                  return _makeGroupData(indexMapelCapaian, nilai,
                      toY: target,
                      isTouched: indexMapelCapaian == _touchedIndex);
                },
              ),
            ),
            swapAnimationDuration: _animDuration,
            swapAnimationCurve: Curves.bounceOut,
          ),
        ),
      ),
    );
  }

  /// [_buildBarTouchData] merupakan function yang mengontrol apapun yang berkaitan dengan event saat Bar di tekan.
  BarTouchData _buildBarTouchData(BuildContext context) => BarTouchData(
        enabled: true,

        /// [touchCallback] merupakan function callback ketika bar di tekan.
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              _touchedIndex = -1;
              return;
            }
            _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },

        /// [BarTouchTooltipData] merupakan tooltip yang akan muncul saat Bar di tekan.
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: context.dp(6),
          tooltipBgColor: context.secondaryColor,
          maxContentWidth: (context.isMobile) ? 140 : 220,
          tooltipPadding: (context.isMobile)
              ? const EdgeInsets.all(6)
              : const EdgeInsets.all(12),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          // Merupakan Widget Tooltip yang akan tampil.
          // TODO: Ganti valuenya dengan data 'Mata Pelajaran\nScore'. ex: 'Matematika\n200'
          getTooltipItem: (_, x, rodData, __) {
            PengerjaanSoal data = _capaianProvider.hasilPengerjaanSoal[x];
            // kInitialKelompokUjian;
            String namaMapelLengkap = 'Undefined';
            if (Constant.kInitialKelompokUjian.containsKey(data.idMapel)) {
              namaMapelLengkap =
                  Constant.kInitialKelompokUjian[data.idMapel]!['nama']!;
            }

            double nilai =
                (_capaianProvider.filterNilai == FilterNilai.mingguan)
                    ? data.pengerjaanMingguan.toDouble()
                    : (_capaianProvider.filterNilai == FilterNilai.bulanan)
                        ? data.pengerjaanBulanan.toDouble()
                        : data.pengerjaanHarian.toDouble();

            double target =
                (_capaianProvider.filterNilai == FilterNilai.mingguan)
                    ? data.targetMingguan.toDouble()
                    : (_capaianProvider.filterNilai == FilterNilai.bulanan)
                        ? data.targetBulanan.toDouble()
                        : data.targetHarian.toDouble();

            double benar =
                (_capaianProvider.filterNilai == FilterNilai.mingguan)
                    ? data.benarMingguan.toDouble()
                    : (_capaianProvider.filterNilai == FilterNilai.bulanan)
                        ? data.benarBulanan.toDouble()
                        : data.benarHarian.toDouble();

            double salah =
                (_capaianProvider.filterNilai == FilterNilai.mingguan)
                    ? data.salahMingguan.toDouble()
                    : (_capaianProvider.filterNilai == FilterNilai.bulanan)
                        ? data.salahBulanan.toDouble()
                        : data.salahHarian.toDouble();

            return BarTooltipItem(
              namaMapelLengkap,
              context.text.labelMedium!.copyWith(color: context.onSecondary),
              textAlign: TextAlign.start,
              children: [
                const TextSpan(
                  text: '\n\n',
                  style: TextStyle(fontSize: 2),
                ),
                TextSpan(
                  text: 'Target: ${nilai.floor()}/${target.floor()}\n',
                  style: context.text.bodySmall!.copyWith(
                    color: context.onSecondary,
                    fontSize: 11,
                  ),
                ),
                TextSpan(
                  text: 'B:${benar.floor()}  S:${salah.floor()}',
                  style: context.text.bodySmall!.copyWith(
                    color: context.onSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          },
        ),
      );

  /// [_buildTitlesData] merupakan function untuk membuat label pada grafik.
  FlTitlesData _buildTitlesData(BuildContext context) => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: min(74, context.dp(56)),
            showTitles: true,
            // TODO: Gunakan singkatan mapel untuk menjadi label.
            getTitlesWidget: (x, meta) {
              int index = x.toInt();
              // kInitialKelompokUjian;
              String initialMapel = ' ???';
              String namaMapel = 'Unidentified';
              if (index < _capaianProvider.hasilPengerjaanSoal.length) {
                PengerjaanSoal data =
                    _capaianProvider.hasilPengerjaanSoal[x.toInt()];
                if (Constant.kInitialKelompokUjian.containsKey(data.idMapel)) {
                  initialMapel =
                      ' ${Constant.kInitialKelompokUjian[data.idMapel]!['initial']}';
                  namaMapel =
                      Constant.kInitialKelompokUjian[data.idMapel]!['nama'] ??
                          'Unidentified';
                }
              }
              return Tooltip(
                message: namaMapel,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(initialMapel,
                      style: context.text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              );
            },
          ),
        ),
        // TODO: Jika ingin menambahkan Target score label, tambahkan pada topTitles
        // NOTE: Target soal rencananya akan ada per mapel.
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (x, meta) {
              List<PengerjaanSoal> pengerjaanSoal =
                  _capaianProvider.hasilPengerjaanSoal;

              if (pengerjaanSoal.isEmpty ||
                  x.toInt() >= pengerjaanSoal.length) {
                return Text('0', style: context.text.bodySmall);
              }
              PengerjaanSoal data = pengerjaanSoal[x.toInt()];

              int target =
                  (_capaianProvider.filterNilai == FilterNilai.mingguan)
                      ? data.targetMingguan
                      : (_capaianProvider.filterNilai == FilterNilai.bulanan)
                          ? data.targetBulanan
                          : data.targetHarian;

              return Text('$target', style: context.text.bodySmall);
            },
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  /// [_makeGroupData] merupakan Group of Bar Chart.<br><br>
  /// [x] merupakan index secara horizontal. Bisa menggunakan hitungan 0,1,2...n<br>
  /// [y] merupakan index secara vertical. Dalam grafik ini adalah score tiap mapel.<br>
  /// [toY] merupakan target jumlah soal dari masing-masing mapel.<br>
  /// [isTouched] merupakan status untuk merubah state Bar ketika ditekan (untuk menampilkan tooltips).<br>
  /// [showTooltips] merupakan array of bool. Gunakan jika ingin mengatur tooltips pada [x] mana yang akan di disable.
  BarChartGroupData _makeGroupData(
    int x,
    double y, {
    double? toY,
    bool isTouched = false,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barsSpace: min(16, context.dp(10)),
      barRods: [
        BarChartRodData(
          fromY: 0,
          width: min(22, context.dp(12)),
          borderRadius: BorderRadius.circular(30),
          toY: isTouched ? y + (y * 0.3) : y,
          color: isTouched ? _touchedBarColor : _barColor,
          backDrawRodData: BackgroundBarChartRodData(
            fromY: 0,
            toY: toY ?? y,
            color: _barBackgroundColor,
            show: true,
          ),
        )
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
