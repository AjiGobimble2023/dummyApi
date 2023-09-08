import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../entity/syarat_tobk.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/chart/progress_bar.dart';

class PopUpTOBKBersyarat extends StatefulWidget {
  final String namaTOB;
  final SyaratTOBK? syaratTOBK;

  /// Untuk keperluan handle push and pop dari empati wajib.
  final String? diBukaDari;

  const PopUpTOBKBersyarat({
    Key? key,
    this.syaratTOBK,
    required this.namaTOB,
    this.diBukaDari,
  }) : super(key: key);

  @override
  State<PopUpTOBKBersyarat> createState() => _PopUpTOBKBersyaratState();
}

class _PopUpTOBKBersyaratState extends State<PopUpTOBKBersyarat> {
  final _scrollControler = ScrollController();

  @override
  void dispose() {
    _scrollControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaleFactor: context.textScale11),
        child: _buildBody(context, widget.syaratTOBK));
  }

  Widget _buildBody(
    BuildContext context,
    SyaratTOBK? syaratTOBK,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 14,
        bottom: context.bottomBarHeight,
      ),
      child: (syaratTOBK == null)
          ? AspectRatio(
              aspectRatio: 3 / 1,
              child: Center(
                child: Text(
                  'Tidak ditemukan prasyarat untuk ${widget.namaTOB}. Coba lagi!',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderLulus(context, syaratTOBK),
                _buildSyaratKelulusan(context),
                ..._buildHasilEmpati(context, syaratTOBK),
                const SizedBox(height: 22),
                ..._buildSubTitle(
                    context, 'Daftar Empati Wajib Prasyarat', null),
                _buildListEmpatiWajib(context, syaratTOBK),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.secondaryContainer,
                      foregroundColor: context.onSecondaryContainer,
                      textStyle: context.text.labelSmall,
                      padding: const EdgeInsets.only(
                          top: 8, bottom: 8, left: 16, right: 8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Masuk TryOut '),
                        Icon(Icons.keyboard_double_arrow_right_rounded,
                            size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildHasilEmpati(BuildContext context, SyaratTOBK syaratTOBK) {
    int jumlahBenar = syaratTOBK.jumlahBenarKumulatif;
    int jumlahSoal = syaratTOBK.jumlahSoalKumulatif;
    double persenBenar = syaratTOBK.percentHasilEmwa;

    return [
      Row(
        children: [
          const Spacer(flex: 5),
          Text(
            'Persen Benar\nKumulatif',
            style: context.text.labelMedium,
          ),
          const Spacer(flex: 4),
          Expanded(
            flex: 50,
            child: CustomProgressBar(
              maxValue: 100.00,
              currentValue: persenBenar,
              backgroundColor: (persenBenar == 0)
                  ? Colors.grey.shade300
                  : (syaratTOBK.isLulus)
                      ? Palette.kSuccessSwatch[300]!
                      : context.primaryContainer,
              progressColor: (persenBenar == 0)
                  ? Colors.grey.shade300
                  : (syaratTOBK.isLulus)
                      ? Palette.kSuccessSwatch[600]!
                      : context.primaryColor,
              border: Border.all(
                  color: (persenBenar == 0)
                      ? Colors.grey
                      : (syaratTOBK.isLulus)
                          ? Palette.kSuccessSwatch[600]!
                          : Palette.kPrimarySwatch[700]!,
                  width: 1.0),
              borderRadius: BorderRadius.circular(64),
              formatValueFixed: 2,
              displayText:
                  (persenBenar <= 0.25 && persenBenar != 0) ? null : ' %   ',
              displayTextStyle: TextStyle(
                color: (persenBenar == 0)
                    ? context.onBackground
                    : (persenBenar <= 25)
                        ? context.onPrimaryContainer
                        : context.onPrimary.withOpacity(0.9),
                fontSize: (context.isMobile) ? 11 : 12,
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          'Jumlah Benar Kumulatif: $jumlahBenar'
          ' dari $jumlahSoal soal',
          style: context.text.bodySmall?.copyWith(
            color: context.onBackground.withOpacity(0.7),
          ),
        ),
      ),
    ];
  }

  Padding _buildSyaratKelulusan(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(flex: 4),
          Text('Syarat\nKelulusan  ', style: context.text.labelMedium),
          const Spacer(flex: 3),
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Math.tex(
                r'\text{ }\frac {\text{Jumlah Benar Kumulatif}}{\text{Jumlah Soal Kumulatif}} '
                r'\geqslant 50 \%',
                mathStyle: MathStyle.display,
                textStyle: context.text.labelLarge,
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  List<Widget> _buildSubTitle(
    BuildContext context,
    String subTitle,
    Widget? child,
  ) =>
      [
        Row(
          children: [
            const SizedBox(width: 10),
            Text(
              subTitle,
              style: context.text.labelMedium,
            ),
            if (child != null) child,
            const Expanded(
              child: Divider(indent: 4, endIndent: 8),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ];

  Widget _buildListEmpatiWajib(BuildContext context, SyaratTOBK syaratTOBK) {
    return (syaratTOBK.listEmpati.isEmpty)
        ? const AspectRatio(
            aspectRatio: 3 / 1,
            child: Center(child: Text('Tidak ada daftar Empati Wajib')))
        : AspectRatio(
            aspectRatio: 2 / 1,
            child: Scrollbar(
              controller: _scrollControler,
              trackVisibility: true,
              thumbVisibility: true,
              radius: const Radius.circular(12),
              child: GridView.builder(
                controller: _scrollControler,
                itemCount: syaratTOBK.listEmpati.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 7 / 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 8,
                    crossAxisCount: 3),
                itemBuilder: (context, index) => _buildItemEmpati(
                  context,
                  syaratTOBK.listEmpati[index],
                ),
              ),
            ),
          );
  }

  Widget _buildItemEmpati(BuildContext context, HasilEMWA empati) {
    int totalPengerjaan = empati.totalPengerjaan;
    int jumlahSoal = empati.jumlahSoal;
    double flexValue = totalPengerjaan / jumlahSoal;

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Palette.kTertiarySwatch[300],
              child: Flex(
                direction: Axis.horizontal,
                verticalDirection: VerticalDirection.down,
                children: [
                  Expanded(
                    flex: (flexValue * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Palette.kTertiarySwatch[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 100 - (flexValue * 100).toInt(),
                    child: const SizedBox.shrink(),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Map<String, dynamic> argument = {
                'idJenisProduk': 72,
                'kodeTOB': empati.kodeTOB,
                'kodePaket': empati.kodePaket,
                'diBukaDari': Constant.kRouteTobkScreen,
              };

              logger.log(
                  'TOBK Dari EMWA >> ${widget.diBukaDari == Constant.kRouteBukuSoalScreen}');
              logger.log('TOBK Dibuka Dari >> ${widget.diBukaDari}');

              if (widget.diBukaDari == Constant.kRouteBukuSoalScreen) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Constant.kRouteBukuSoalScreen,
                  (route) => route.isFirst,
                  arguments: argument,
                );
              } else {
                Navigator.pushNamed(context, Constant.kRouteBukuSoalScreen,
                    arguments: argument);
              }
            },
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.tertiaryColor),
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(
                              empati.kodePaket,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
                              textScaleFactor: context.textScale12,
                              style: context.text.labelMedium?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Palette.kTertiarySwatch[600],
                              ),
                            ),
                          ),
                          Text(
                            '${empati.totalPengerjaan} dari ${empati.jumlahSoal} soal',
                            style: context.text.bodySmall?.copyWith(
                              fontSize: 9,
                              color: Palette.kTertiarySwatch[600],
                            ),
                          )
                        ],
                      ),
                    ),
                    VerticalDivider(
                        color: context.hintColor,
                        thickness: 0.4,
                        width: 8,
                        indent: 10,
                        endIndent: 10),
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      size: 16,
                      color: (!empati.sudahMengerjakan)
                          ? context.disableColor
                          : context.tertiaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container _buildHeaderLulus(BuildContext context, SyaratTOBK syaratTOBK) {
    return Container(
      padding: const EdgeInsets.only(left: 8, bottom: 10, top: 6),
      decoration: BoxDecoration(
          color: (syaratTOBK.isLulus)
              ? Palette.kSuccessSwatch[500]
              : context.primaryColor,
          border: Border.all(
              color: (syaratTOBK.isLulus)
                  ? Palette.kSuccessSwatch[700]!
                  : Palette.kPrimarySwatch[700]!,
              width: 2),
          borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Icon(
            (syaratTOBK.isLulus)
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            color: context.onPrimary.withOpacity(0.9),
            size: 32,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              maxLines: 2,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: context.textScale12,
              text: TextSpan(
                text: (syaratTOBK.isLulus)
                    ? 'Lulus EMWA\n'
                    : 'Tidak Memenuhi EMWA\n',
                style: context.text.titleMedium?.copyWith(
                  color: context.onPrimary,
                ),
                children: [
                  TextSpan(
                    text: 'Prasyarat ${widget.namaTOB}',
                    style: context.text.bodySmall?.copyWith(
                      color: context.onPrimary.withOpacity(0.9),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
