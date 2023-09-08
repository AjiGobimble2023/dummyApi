import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../../core/config/extensions.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../core/config/global.dart';
import '../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';
import '../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../entity/laporan_vak.dart';
import '../provider/laporan_vak_provider.dart';

class LaporanVakWidget extends StatefulWidget {
  final EdgeInsets? padding;
  final BorderRadiusGeometry? headerBorderRadius;
  final bool isLandscape;

  const LaporanVakWidget({
    Key? key,
    this.padding,
    this.headerBorderRadius,
    this.isLandscape = false,
  }) : super(key: key);

  @override
  State<LaporanVakWidget> createState() => _LaporanVakWidgetState();
}

class _LaporanVakWidgetState extends State<LaporanVakWidget> {
  final _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  Future<LaporanVAK?> _onRefresh({bool isRefresh = false}) async {
    return await context.read<LaporanVakProvider>().loadLaporanVak(
        isRefresh: isRefresh,
        noRegistrasi: _authProvider.userData!.noRegistrasi,
        userType: _authProvider.userData!.siapa);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<LaporanVakProvider, LaporanVAK?>(
      selector: (_, laporan) =>
          laporan.getLaporanVAKByNoReg(_authProvider.userData!.noRegistrasi),
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, laporanVAK, loadingWidget) =>
          FutureBuilder<LaporanVAK?>(
        future: _onRefresh(),
        builder: (context, vakSnapshot) {
          bool isLoading =
              vakSnapshot.connectionState == ConnectionState.waiting ||
                  context.select<LaporanVakProvider, bool>(
                      (laporan) => laporan.isLoadingLaporanVAK);
          LaporanVAK? hasilVAK = vakSnapshot.data ?? laporanVAK;

          if (isLoading) {
            return loadingWidget!;
          }

          logger.log('DATA VAK >> $hasilVAK');

          Widget basicEmpty = BasicEmpty(
            isLandscape: widget.isLandscape,
            shrink: (context.dh < 600) ? !context.isMobile : false,
            imageUrl: 'ilustrasi_profiling.png'.illustration,
            title: 'Hasil Tes VAK',
            subTitle: 'Belum Ada Hasil Tes VAK',
            emptyMessage:
                'Hai Sobat! MinGO tidak menemukan hasil tes VAK kamu. '
                'Sepertinya kamu belum mengerjakan Soal VAK ya. '
                'Kerjakan Soal VAK yuk Sobat, cek di menu 3B - Profiling yaa!',
          );

          return CustomSmartRefresher(
            controller: _refreshController,
            onRefresh: () => _onRefresh(isRefresh: true),
            isDark: true,
            child: (hasilVAK == null)
                ? ((context.isMobile || context.dh > 600 || widget.isLandscape)
                    ? basicEmpty
                    : SingleChildScrollView(child: basicEmpty))
                : (!widget.isLandscape)
                    ? ListView(
                        padding: EdgeInsets.only(
                          top: context.dp(20),
                          bottom: context.dp(42),
                          left: context.dp(16),
                          right: context.dp(16),
                        ),
                        children: [
                          _buildHeaderWidget(context, hasilVAK),
                          _buildTitle(context, 'Saran Belajar'),
                          SizedBox(height: context.dp(12)),
                          Text(
                            _formatMessage(hasilVAK.kecenderungan),
                            style: context.text.bodyMedium?.copyWith(
                              color: context.onBackground.withOpacity(0.76),
                            ),
                          ),
                          ..._buildTipsItem(1, hasilVAK.judul1, hasilVAK.isi1),
                          if (hasilVAK.judul2 != null)
                            ..._buildTipsItem(
                                2, hasilVAK.judul2!, hasilVAK.isi2!),
                          if (hasilVAK.judul3 != null)
                            ..._buildTipsItem(
                                3, hasilVAK.judul3!, hasilVAK.isi3!),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildHeaderWidget(context, hasilVAK),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.cancel_outlined),
                                    label: const Text('Tutup laporan'),
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16)),
                                  )
                                ],
                              ),
                            ),
                            const VerticalDivider(indent: 32, endIndent: 32),
                            Expanded(
                              child: Scrollbar(
                                controller: _scrollController,
                                thickness: 8,
                                trackVisibility: true,
                                thumbVisibility: true,
                                radius: const Radius.circular(12),
                                child: ListView(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(
                                      right: 24, left: 32),
                                  children: [
                                    _buildTitle(context, 'Saran Belajar'),
                                    const SizedBox(height: 16),
                                    Text(
                                      _formatMessage(hasilVAK.kecenderungan),
                                      style: context.text.bodyMedium?.copyWith(
                                        color: context.onBackground
                                            .withOpacity(0.76),
                                      ),
                                    ),
                                    ..._buildTipsItem(
                                        1, hasilVAK.judul1, hasilVAK.isi1),
                                    if (hasilVAK.judul2 != null)
                                      ..._buildTipsItem(
                                          2, hasilVAK.judul2!, hasilVAK.isi2!),
                                    if (hasilVAK.judul3 != null)
                                      ..._buildTipsItem(
                                          3, hasilVAK.judul3!, hasilVAK.isi3!),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          );
        },
      ),
      child: _buildLoadingWidget(context),
    );
  }

  String _formatMessage(String vakDominan) {
    bool isOrtu = _authProvider.isOrtu;
    final dominan = vakDominan.split(' ');

    var newDominan = dominan[0];

    if (dominan.length == 2) {
      newDominan = '${dominan[0]} & ${dominan[1]}';
    } else if (dominan.length == 3) {
      newDominan = '${dominan[0]}, ${dominan[1]} & ${dominan[2]}';
    }

    return (isOrtu)
        ? 'Hasil ini menunjukkan bahwa putra/i Bapak/Ibu memiliki kecenderungan '
            'cara belajar $newDominan. Untuk mencapai hasil belajar yang optimal kami '
            'memberikan tip belajar sebagai berikut :'
        : 'Dari hasil tes VAK kamu, '
            'MinGO menyimpulkan kalau gaya belajar kamu cenderung $newDominan. '
            'MinGO punya saran nih buat kamu Sobat GO agar belajar lebih optimal lohh! Coba simak saran dari MinGO yaa';
  }

  Row _buildTitle(BuildContext context, String title,
          {bool isSubTitle = false}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style:
                isSubTitle ? context.text.titleMedium : context.text.titleLarge,
          ),
          const Expanded(
            child: Divider(
                thickness: 1, indent: 8, endIndent: 8, color: Colors.black26),
          ),
        ],
      );

  Widget _buildLoadingWidget(BuildContext context) {
    Widget illustration = AspectRatio(
      aspectRatio: (context.isMobile || widget.isLandscape) ? 1 : 5 / 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ShimmerWidget.rounded(
            width: (!widget.isLandscape)
                ? (min(650, (context.isMobile) ? context.dw : context.dh)) *
                    0.64
                : 280,
            height: (!widget.isLandscape)
                ? (min(650, (context.isMobile) ? context.dw : context.dh)) *
                    0.64
                : 280,
            borderRadius: BorderRadius.circular(12),
          ),
          Column(
            mainAxisSize: (context.isMobile || !widget.isLandscape)
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < 3; i++)
                ShimmerWidget.rounded(
                  width: (!widget.isLandscape)
                      ? (min(650,
                              (context.isMobile) ? context.dw : context.dh)) *
                          0.2
                      : 86,
                  height: (!widget.isLandscape)
                      ? (min(650,
                              (context.isMobile) ? context.dw : context.dh)) *
                          0.2
                      : 86,
                  borderRadius: BorderRadius.circular(12),
                ),
            ],
          ),
        ],
      ),
    );

    List<Widget> textList = [
      Padding(
        padding: EdgeInsets.only(
          top: min(24, context.dp(20)),
          bottom: min(16, context.dp(14)),
          right: min(200, context.dw * 0.5),
        ),
        child: ShimmerWidget.rounded(
          width: double.infinity,
          height: min(34, context.dp(32)),
          borderRadius: gDefaultShimmerBorderRadius,
        ),
      ),
      for (int i = 0; i < 4; i++)
        Padding(
          padding: EdgeInsets.only(
            bottom: min(13, context.dp(11)),
          ),
          child: ShimmerWidget.rounded(
            width: double.infinity,
            height: min(24, context.dp(22)),
            borderRadius: gDefaultShimmerBorderRadius,
          ),
        ),
      Padding(
        padding: EdgeInsets.only(
          top: min(10, context.dp(8)),
          bottom: min(14, context.dp(12)),
          right: min(240, context.dw * 0.64),
        ),
        child: ShimmerWidget.rounded(
          width: double.infinity,
          height: min(28, context.dp(26)),
          borderRadius: gDefaultShimmerBorderRadius,
        ),
      ),
      for (int i = 0; i < 4; i++)
        Padding(
          padding: EdgeInsets.only(
            bottom: min(13, context.dp(11)),
          ),
          child: ShimmerWidget.rounded(
            width: double.infinity,
            height: min(24, context.dp(22)),
            borderRadius: gDefaultShimmerBorderRadius,
          ),
        ),
    ];

    return (!widget.isLandscape)
        ? ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              vertical: min(22, context.dp(20)),
              horizontal: min(18, context.dp(16)),
            ),
            children: [illustration, ...textList],
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Row(
              children: [
                Expanded(child: illustration),
                const VerticalDivider(width: 32, indent: 32, endIndent: 32),
                Expanded(
                  child: ListView(children: textList),
                ),
              ],
            ),
          );
  }

  AspectRatio _buildHeaderWidget(BuildContext context, LaporanVAK hasilVAK) =>
      AspectRatio(
        aspectRatio: (context.isMobile || widget.isLandscape) ? 1 : 5 / 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomImageNetwork.rounded(
              'ilustrasi_profiling.png'.illustration,
              width: (!widget.isLandscape)
                  ? (min(650, (context.isMobile) ? context.dw : context.dh)) *
                      0.64
                  : 280,
              height: (!widget.isLandscape)
                  ? (min(650, (context.isMobile) ? context.dw : context.dh)) *
                      0.64
                  : 280,
              shrinkShimmer: true,
              borderRadius: BorderRadius.circular(12),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 3; i++)
                  _buildScoreItem(context, i, hasilVAK),
              ],
            ),
          ],
        ),
      );

  Container _buildScoreItem(BuildContext context, int i, LaporanVAK hasilVAK) =>
      Container(
        padding: const EdgeInsets.all(8),
        constraints: BoxConstraints(
          minWidth: (!widget.isLandscape)
              ? (min(650, (context.isMobile) ? context.dw : context.dh)) * 0.2
              : 86,
          maxHeight: (!widget.isLandscape)
              ? (min(650, (context.isMobile) ? context.dw : context.dh)) * 0.2
              : 86,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.5, 1.0],
              colors: [
                context.background,
                context.secondaryColor,
              ],
            ),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  spreadRadius: -2,
                  offset: Offset(0, 4))
            ]),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            textScaleFactor: context.textScale12,
            textAlign: TextAlign.center,
            text: TextSpan(
                text:
                    '${(i == 0) ? hasilVAK.scoreVisual : (i == 1) ? hasilVAK.scoreAuditory : hasilVAK.scoreKinesthetic}\n',
                style: context.text.titleLarge,
                children: [
                  TextSpan(
                      text:
                          'Poin\n${(i == 0) ? 'Visual' : (i == 1) ? 'Auditori' : 'Kinestetis'}',
                      style: context.text.labelSmall),
                ]),
          ),
        ),
      );

  List<Widget> _buildTipsItem(int nomor, String title, String isi) => [
        SizedBox(height: min(22, context.dp(20))),
        _buildTitle(
            context, '$nomor) ${title.sentenceCase.replaceAll(':', '')}',
            isSubTitle: true),
        SizedBox(height: min(14, context.dp(12))),
        Padding(
          padding: EdgeInsets.only(left: min(14, context.dp(12))),
          child: Text(
            isi,
            style: context.text.bodyMedium?.copyWith(
              color: context.onBackground.withOpacity(0.76),
            ),
          ),
        ),
      ];
}
