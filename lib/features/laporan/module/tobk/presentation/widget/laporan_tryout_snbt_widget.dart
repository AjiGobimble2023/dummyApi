import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/builder/responsive_builder.dart';
import 'laporan_tryout_detail_nilai_widget.dart';
import 'laporan_tryout_profil_nilai_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../provider/laporan_tryout_provider.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';

class LaporanTryoutLaporanSNBTWidget extends StatefulWidget {
  final String? namaTOB;
  final String? kodeTOB;
  final String? penilaian;
  final String? link;

  const LaporanTryoutLaporanSNBTWidget({
    super.key,
    this.namaTOB,
    this.kodeTOB,
    this.penilaian,
    this.link,
  });

  @override
  State<LaporanTryoutLaporanSNBTWidget> createState() =>
      _LaporanTryoutLaporanSNBTWidgetState();
}

class _LaporanTryoutLaporanSNBTWidgetState
    extends State<LaporanTryoutLaporanSNBTWidget> {
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  @override
  Widget build(BuildContext context) {
    final userId = _authProvider.userData!.noRegistrasi;
    final userClassLevelId = _authProvider.userData!.idSekolahKelas;
    final userType = _authProvider.userData!.siapa;
    final userPtn1Id = _authProvider.userData!.idJurusanPilihan1.toString();
    final userPtn2Id = _authProvider.userData!.idJurusanPilihan2.toString();
    final kodeTOB = widget.kodeTOB;
    final penilaian = widget.penilaian;

    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<LaporanTryoutProvider>().loadLaporanNilai(
            userId: userId,
            userClassLevelId: userClassLevelId,
            userType: userType,
            kodeTOB: kodeTOB,
            penilaian: penilaian,
            pilihan1: userPtn1Id,
            pilihan2: userPtn2Id,
          ),
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
              ? snapshot.hasError
                  ? NoDataFoundWidget(
                      subTitle: widget.namaTOB.toString(),
                      emptyMessage: '${snapshot.error}')
                  : ResponsiveBuilder(
                      tablet: Row(children: [
                        LaporanTryoutSNBTProfilNilai(
                            widget.namaTOB!, snapshot.data!, widget.link!),
                        LaporanTryoutSNBTDetailNilai(
                          snapshot.data!['nilai'],
                          widget.namaTOB!,
                        ),
                      ]),
                      mobile: DefaultTabController(
                        initialIndex: 0,
                        length: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                top: context.pd,
                                right: context.pd,
                                left: context.pd,
                              ),
                              decoration: BoxDecoration(
                                  color: context.background,
                                  borderRadius: BorderRadius.circular(300),
                                  boxShadow: const [
                                    BoxShadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                        color: Colors.black26)
                                  ]),
                              child: TabBar(
                                labelColor: context.background,
                                indicatorColor: context.primaryColor,
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelStyle: context.text.bodyMedium,
                                unselectedLabelStyle: context.text.bodyMedium,
                                dividerColor: Colors.transparent,
                                unselectedLabelColor: context.onBackground,
                                splashBorderRadius: BorderRadius.circular(300),
                                indicator: BoxDecoration(
                                    color: context.primaryColor,
                                    borderRadius: BorderRadius.circular(300)),
                                indicatorPadding: EdgeInsets.zero,
                                labelPadding: EdgeInsets.zero,
                                tabs: const [
                                  Tab(text: 'Profil Nilai'),
                                  Tab(text: 'Detail Nilai')
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: context.pd - 5),
                                child: TabBarView(
                                  physics: const ClampingScrollPhysics(),
                                  children: [
                                    LaporanTryoutSNBTProfilNilai(
                                        widget.namaTOB!,
                                        snapshot.data!,
                                        widget.link!),
                                    LaporanTryoutSNBTDetailNilai(
                                      snapshot.data!['nilai'],
                                      widget.namaTOB!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
              : const LoadingWidget(),
    );
  }
}
