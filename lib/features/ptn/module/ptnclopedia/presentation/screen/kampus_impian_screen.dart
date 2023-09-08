import 'dart:developer' as logger show log;

import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../provider/ptn_provider.dart';
import '../widget/kampus_impian/riwayat_item.dart';
import '../widget/kampus_impian/kampus_pilihan_item.dart';
import '../../entity/kampus_impian.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/helper/hive_helper.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/separator/dash_divider.dart';

class KampusImpianScreen extends StatefulWidget {
  const KampusImpianScreen({Key? key}) : super(key: key);

  @override
  State<KampusImpianScreen> createState() => _KampusImpianScreenState();
}

class _KampusImpianScreenState extends State<KampusImpianScreen> {
  late final _authOtpProvider = context.read<AuthOtpProvider>();

  @override
  void dispose() {
    if (HiveHelper.isBoxOpen<KampusImpian>(
        boxName: HiveHelper.kRiwayatKampusImpianBox)) {
      HiveHelper.closeBox<KampusImpian>(
          boxName: HiveHelper.kRiwayatKampusImpianBox);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                context.primaryColor,
                context.secondaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.3, 1]),
        ),
        child: FutureBuilder<void>(
          future: _onRefresh(),
          builder: (context, snapshot) {
            final bool isLoading = snapshot.connectionState ==
                    ConnectionState.waiting ||
                context.select<PtnProvider, bool>((ptn) => ptn.isLoadingImpian);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                _buildAppBar(context),
                if (!context.isMobile)
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 28,
                      right: 28,
                    ),
                    sliver: SliverFillRemaining(
                      fillOverscroll: false,
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                _buildKampusImpianPilihan(context, isLoading),
                          ),
                          _buildDashSeparator(context),
                          Expanded(
                            child: _buildRiwayatPilihan(context, isLoading),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (context.isMobile)
                  _buildKampusImpianPilihan(context, isLoading),
                if (context.isMobile) _buildDashSeparator(context),
                if (context.isMobile) _buildRiwayatPilihan(context, isLoading),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh({bool isRefresh = false}) async {
    await context.read<PtnProvider>().getKampusImpian(
          isRefresh: isRefresh,
          noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
          isOrtu: _authOtpProvider.userData?.isOrtu ?? false,
        );
  }

  Widget _buildKampusImpianPilihan(BuildContext context, bool isLoading) {
    if (!context.isMobile) {
      return (isLoading)
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KampusPilihanItem(isLoading: true),
                KampusPilihanItem(isLoading: true, pilihanKe: 2),
              ],
            )
          : ValueListenableBuilder<Box<KampusImpian>>(
              valueListenable: HiveHelper.listenableKampusImpian(),
              builder: (_, boxPilihan, loadingWidget) {
                final List<KampusImpian> listKampusPilihan =
                    boxPilihan.values.toList();

                if (listKampusPilihan.isEmpty) {
                  return KampusPilihanItem(isOrtu: _authOtpProvider.isOrtu);
                }

                if (kDebugMode) {
                  logger.log(
                      'KAMPUS_IMPIAN_SCREEN-KampusImpianPilihan: length >> ${listKampusPilihan.length}');
                }

                return Column(
                  children: List<Widget>.generate(2, (index) {
                    if (listKampusPilihan.length < 2 && index > 0) {
                      return KampusPilihanItem(
                        pilihanKe: 2,
                        isOrtu: _authOtpProvider.isOrtu,
                      );
                    }

                    return KampusPilihanItem(
                      pilihanKe: index + 1,
                      kampusImpian: listKampusPilihan[index],
                      isOrtu: _authOtpProvider.isOrtu,
                    );
                  }),
                );
              },
            );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dp(20),
        vertical: context.dp(18),
      ),
      sliver: (isLoading)
          ? const SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  KampusPilihanItem(isLoading: true),
                  KampusPilihanItem(isLoading: true, pilihanKe: 2),
                ],
              ),
            )
          : ValueListenableBuilder<Box<KampusImpian>>(
              valueListenable: HiveHelper.listenableKampusImpian(),
              builder: (_, boxPilihan, loadingWidget) {
                final List<KampusImpian> listKampusPilihan =
                    boxPilihan.values.toList();

                if (listKampusPilihan.isEmpty) {
                  return SliverToBoxAdapter(
                    child: KampusPilihanItem(isOrtu: _authOtpProvider.isOrtu),
                  );
                }

                if (kDebugMode) {
                  logger.log(
                      'KAMPUS_IMPIAN_SCREEN-KampusImpianPilihan: length >> ${listKampusPilihan.length}');
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      if (listKampusPilihan.length < 2 && index > 0) {
                        return KampusPilihanItem(
                          pilihanKe: 2,
                          isOrtu: _authOtpProvider.isOrtu,
                        );
                      }

                      return KampusPilihanItem(
                        pilihanKe: index + 1,
                        kampusImpian: listKampusPilihan[index],
                        isOrtu: _authOtpProvider.isOrtu,
                      );
                    },
                    childCount: 2,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRiwayatPilihan(BuildContext context, bool isLoading) {
    if (!context.isMobile) {
      return (isLoading)
          ? ListView(
              children: const [
                RiwayatPilihan(),
                RiwayatPilihan(),
                RiwayatPilihan(),
                RiwayatPilihan(),
              ],
            )
          : ValueListenableBuilder<Box<KampusImpian>>(
              valueListenable: HiveHelper.listenableRiwayatKampusImpian(),
              builder: (context, boxRiwayat, loadingWidget) {
                List<KampusImpian> riwayatPilihan = boxRiwayat.values.toList();

                if (riwayatPilihan.isEmpty) {
                  return BasicEmpty(
                    shrink: true,
                    imageUrl: Constant.kStoryBoard['Impian']!['imgUrl'],
                    title: Constant.kStoryBoard['Impian']!['title'],
                    subTitle: Constant.kStoryBoard['Impian']!['subTitle'],
                    emptyMessage: Constant.kStoryBoard['Impian']!['storyText'],
                  );
                }

                riwayatPilihan
                    .sort((a, b) => a.tanggalPilih.compareTo(b.tanggalPilih));
                riwayatPilihan = riwayatPilihan.reversed.toList();

                return ListView.builder(
                  itemBuilder: (context, index) =>
                      RiwayatPilihan(kampusRiwayat: riwayatPilihan[index]),
                  itemCount: riwayatPilihan.length,
                );
              },
            );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        vertical: context.dp(30),
        horizontal: context.dp(20),
      ),
      sliver: (isLoading)
          ? const SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  RiwayatPilihan(),
                  RiwayatPilihan(),
                  RiwayatPilihan(),
                  RiwayatPilihan(),
                ],
              ),
            )
          : ValueListenableBuilder<Box<KampusImpian>>(
              valueListenable: HiveHelper.listenableRiwayatKampusImpian(),
              builder: (context, boxRiwayat, loadingWidget) {
                List<KampusImpian> riwayatPilihan = boxRiwayat.values.toList();

                if (riwayatPilihan.isEmpty) {
                  return SliverToBoxAdapter(
                    child: BasicEmpty(
                      shrink: true,
                      imageUrl: Constant.kStoryBoard['Impian']!['imgUrl'],
                      title: Constant.kStoryBoard['Impian']!['title'],
                      subTitle: Constant.kStoryBoard['Impian']!['subTitle'],
                      emptyMessage:
                          Constant.kStoryBoard['Impian']!['storyText'],
                    ),
                  );
                }

                riwayatPilihan
                    .sort((a, b) => a.tanggalPilih.compareTo(b.tanggalPilih));
                riwayatPilihan = riwayatPilihan.reversed.toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) =>
                        RiwayatPilihan(kampusRiwayat: riwayatPilihan[index]),
                    childCount: riwayatPilihan.length,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDashSeparator(BuildContext context) {
    if (!context.isMobile) {
      return SizedBox(
        width: 82,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              top: 0,
              bottom: 0,
              child: DashedDivider(
                dashColor: context.onPrimary,
                strokeWidth: 3,
                dash: 6,
                direction: Axis.vertical,
              ),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: Chip(
                label: const Text('Riwayat Pilihan'),
                labelStyle: context.text.bodyMedium,
                backgroundColor: context.background,
                surfaceTintColor: context.onBackground,
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              ),
            )
          ],
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        width: double.infinity,
        height: context.dp(32),
        child: Stack(
          alignment: Alignment.center,
          children: [
            DashedDivider(
              dashColor: context.onPrimary,
              strokeWidth: 2,
              dash: 6,
              direction: Axis.horizontal,
            ),
            Chip(
              label: const Text('Riwayat Pilihan'),
              labelStyle: context.text.bodyMedium,
              backgroundColor: context.background,
              surfaceTintColor: context.onBackground,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            )
          ],
        ),
      ),
    );
  }

  Theme _buildAppBar(BuildContext context) {
    return Theme(
      data: context.themeData.copyWith(
        colorScheme: context.colorScheme.copyWith(
          onSurface: context.onPrimary,
          onSurfaceVariant: context.onPrimary,
        ),
      ),
      child: SliverAppBar.large(
        pinned: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          iconSize: 32,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        backgroundColor: context.primaryColor,
        title: const Text('Kampus Impian Kamu'),
      ),
    );
  }
}
