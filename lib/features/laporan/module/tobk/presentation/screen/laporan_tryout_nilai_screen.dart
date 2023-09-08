import 'package:flutter/material.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';

import '../../../../../../core/config/constant.dart';
import '../../../../../../core/shared/widget/exception/exception_widget.dart';
import '../widget/layout/laporan_tryout_4bs_widget.dart';
import '../widget/layout/laporan_tryout_akm_widget.dart';
import '../widget/layout/laporan_tryout_bs_or_b_widget.dart';
import '../widget/laporan_tryout_snbt_widget.dart';
import '../widget/layout/laporan_tryout_stan_widget.dart';

class LaporanTryoutNilaiScreen extends StatelessWidget {
  const LaporanTryoutNilaiScreen({
    Key? key,
    required this.penilaian,
    required this.kodeTOB,
    required this.namaTOB,
    required this.isExist,
    required this.link,
    required this.jenisTO,
    required this.showEPB,
  }) : super(key: key);
  final String penilaian;
  final String kodeTOB;
  final String namaTOB;
  final bool isExist;
  final String link;
  final String jenisTO;
  final bool showEPB;

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'Progress Tryout',
      body: _setLaporanLayout(
        namaTOB,
        kodeTOB,
        penilaian,
      ),

      /// Widget floatingActionButton untuk Lihat EPB
      floatingActionButton: Visibility(
        visible: showEPB,
        child: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween(
              begin: const Offset(2.0, 0.0),
              end: const Offset(0.0, 0.0),
            ).animate(anim),
            child: child,
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              if (isExist) {
                Navigator.of(context).pushNamed(
                  Constant.kRouteLaporanTryOutViewer,
                  arguments: {'title': 'EPB $namaTOB', 'link': link},
                );
              } else {
                gShowBottomDialogInfo(context,
                    message: "Saat ini EPB-nya masih belum tersedia Sobat");
              }
            },
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Lihat EPB'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.secondaryContainer,
              foregroundColor: context.onSecondaryContainer,
              padding: EdgeInsets.all(context.pd),
            ),
          ),
        ),
      ),
    );
  }

  /// [_setLaporanLayout] widget layout laporan nilai TO berdasakan jenis penilaian TO
  Widget _setLaporanLayout(String namaTOB, String kodeTOB, String penilaian) {
    switch (penilaian) {
      case '4B-S':
        return LaporanTryoutLaporan4BSWidget(
          namaTOB: namaTOB,
          kodeTOB: kodeTOB,
          penilaian: penilaian,
        );
      case 'B-S':
      case 'B Saja':
        return LaporanTryoutLaporanBSorBWidget(
          namaTOB: namaTOB,
          kodeTOB: kodeTOB,
          penilaian: penilaian,
        );
      case 'IRT':
        if (jenisTO != "STAN") {
          return LaporanTryoutLaporanSNBTWidget(
            namaTOB: namaTOB,
            kodeTOB: kodeTOB,
            penilaian: penilaian,
            link: link,
          );
        } else {
          return LaporanTryoutLaporanSTANWidget(
              namaTOB: namaTOB,
              kodeTOB: kodeTOB,
              penilaian: penilaian,
              jenisTO: jenisTO);
        }
      case 'AKM':
        return LaporanTryoutLaporanAKMWidget(
          namaTOB: namaTOB,
          kodeTOB: kodeTOB,
          penilaian: penilaian,
        );

      case 'STAN':
        return LaporanTryoutLaporanSTANWidget(
            namaTOB: namaTOB,
            kodeTOB: kodeTOB,
            penilaian: penilaian,
            jenisTO: jenisTO);
      default:
        return const ExceptionWidget(
          'Data nilai Tryout tidak ditemukan',
          exceptionMessage: '',
        );
    }
  }
}
