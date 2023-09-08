import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../entity/kampus_impian.dart';
import '../../provider/ptn_provider.dart';
import '../../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../../core/config/constant.dart';
import '../../../../../../../core/config/extensions.dart';
import '../../../../../../../core/helper/hive_helper.dart';
import '../../../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../../../core/shared/widget/loading/shimmer_widget.dart';

class ImpianKuliahWidget extends StatefulWidget {
  const ImpianKuliahWidget({Key? key}) : super(key: key);

  @override
  State<ImpianKuliahWidget> createState() => _ImpianKuliahWidgetState();
}

class _ImpianKuliahWidgetState extends State<ImpianKuliahWidget> {
  late final _authOtpProvider = context.read<AuthOtpProvider>();

  Future<void> _onRefresh({bool isRefresh = false}) async {
    if (_authOtpProvider.isLogin && !_authOtpProvider.isTamu) {
      await context.read<PtnProvider>().getKampusImpian(
            isRefresh: isRefresh,
            fromHome: true,
            noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
            isOrtu: _authOtpProvider.userData?.isOrtu ?? false,
          );
    } else {
      if (!HiveHelper.isBoxOpen<KampusImpian>(
          boxName: HiveHelper.kKampusImpianBox)) {
        await HiveHelper.openBox<KampusImpian>(
            boxName: HiveHelper.kKampusImpianBox);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AuthOtpProvider, bool>(
      selector: (context, auth) =>
          auth.isLogin &&
          (auth.isKelasSMA || auth.isKelasAlumni) &&
          !auth.isTamu,
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, isShowKampusImpian, notLoginWidget) =>
          (isShowKampusImpian)
              ? FutureBuilder<void>(
                  future: _onRefresh(),
                  builder: (_, snapshot) {
                    bool isLoading =
                        snapshot.connectionState == ConnectionState.waiting;

                    if (isLoading) {
                      return _buildLoadingWidget(context);
                    }

                    return CustomCard(
                      onTap: () => _onImpianClicked(context),
                      padding: EdgeInsets.symmetric(
                        vertical:
                            (context.isMobile) ? context.dp(10) : context.dp(5),
                        horizontal:
                            (context.isMobile) ? context.dp(12) : context.dp(6),
                      ),
                      child: ValueListenableBuilder<Box<KampusImpian>>(
                        valueListenable: HiveHelper.listenableKampusImpian(),
                        builder: (context, boxImpian, _) {
                          KampusImpian? kampusImpian;

                          if (boxImpian.values.isNotEmpty) {
                            kampusImpian = boxImpian.values.first;
                          }

                          return _buildKampusImpianDisplay(
                              context, kampusImpian);
                        },
                      ),
                    );
                  },
                )
              : notLoginWidget!,
      child: CustomCard(
        onTap: () => _onImpianClicked(context),
        padding: EdgeInsets.symmetric(
          vertical: (context.isMobile) ? context.dp(10) : context.dp(5),
          horizontal: (context.isMobile) ? context.dp(12) : context.dp(6),
        ),
        child: _buildKampusImpianDisplay(context, null),
      ),
    );
  }

  /// NOTE: Tempat menyimpan seluruh private function---------------------------
  void _onImpianClicked(BuildContext context) {
    final authOtpProvider = context.read<AuthOtpProvider>();

    if (authOtpProvider.isLogin &&
        !authOtpProvider.isTamu &&
        (authOtpProvider.isKelasSMA || authOtpProvider.isKelasAlumni)) {
      Navigator.pushNamed(
        context,
        Constant.kRouteImpian,
      );
    } else {
      Navigator.pushNamed(
        context,
        Constant.kRouteStoryBoardScreen,
        arguments: Constant.kStoryBoard['Impian'],
      );
    }
  }

  Row _buildKampusImpianDisplay(
      BuildContext context, KampusImpian? kampusImpian) {
    return Row(
      children: [
        Image.asset(
          'assets/icon/ic_ptn.webp',
          width: (context.isMobile) ? context.dp(32) : context.dp(22),
          fit: BoxFit.fitWidth,
        ),
        SizedBox(width: context.dp(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (kampusImpian == null)
                    ? 'Atur target kamu yuk sobat!'
                    : 'Impian Kuliah Kamu',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    context.text.bodySmall?.copyWith(color: context.hintColor),
              ),
              (kampusImpian == null)
                  ? Text('Impian Kamu Kuliah Dimana?',
                      semanticsLabel: 'Impian Kamu Kuliah Dimana?',
                      style: context.text.titleSmall)
                  : Hero(
                      tag: 'impian-nama-ptn',
                      transitionOnUserGestures: true,
                      child: Text(
                          '${kampusImpian.aliasPTN} - ${kampusImpian.namaJurusan}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall)),
              if (kampusImpian != null)
                Hero(
                  tag: 'impian-peminat-tampung',
                  transitionOnUserGestures: true,
                  child: Text(
                    '${kampusImpian.peminat} | ${kampusImpian.tampung}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.hintColor),
                  ),
                ),
            ],
          ),
        ),
        Icon(Icons.chevron_right,
            color: context.primaryColor, semanticLabel: 'Chevron Right Icon')
      ],
    );
  }

  CustomCard _buildLoadingWidget(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.symmetric(
        vertical: (context.isMobile) ? context.dp(10) : context.dp(5),
        horizontal: (context.isMobile) ? context.dp(12) : context.dp(6),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icon/ic_ptn.webp',
            width: context.dp(32),
            fit: BoxFit.fitWidth,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rounded(
                    width: context.dp(160),
                    height: context.dp(14),
                    borderRadius: BorderRadius.circular(46)),
                const SizedBox(height: 4),
                ShimmerWidget.rounded(
                    width: double.infinity,
                    height: context.dp(18),
                    borderRadius: BorderRadius.circular(46)),
                const SizedBox(height: 4),
                ShimmerWidget.rounded(
                    width: context.dp(190),
                    height: context.dp(14),
                    borderRadius: BorderRadius.circular(46))
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right,
              color: context.primaryColor, semanticLabel: 'Chevron Right Icon')
        ],
      ),
    );
  }
}
