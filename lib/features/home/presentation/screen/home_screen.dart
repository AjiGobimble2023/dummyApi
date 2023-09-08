import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/constant.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/shared/widget/image/custom_image_network.dart';
import '../widget/carousel_widget.dart';
import '../../../auth/model/user_model.dart';
import '../../../home/presentation/widget/user_info_app_bar.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../berita/presentation/provider/berita_provider.dart';
import '../../../ptn/module/ptnclopedia/presentation/widget/home/impian_kuliah_widget.dart';
import '../../../kehadiran/presentation/provider/kehadiran_provider.dart';
import '../../../berita/presentation/widget/promo/promo_home_widget.dart';
import '../../../leaderboard/presentation/provider/capaian_provider.dart';
import '../../../pembayaran/presentation/provider/pembayaran_provider.dart';
import '../../../berita/presentation/widget/go_news/go_news_home_widget.dart';
import '../../../bookmark/presentation/widget/home/bookmark_home_widget.dart';
import '../../../video/presentation/widget/home/teaser_video_home_widget.dart';
import '../../../leaderboard/presentation/provider/leaderboard_provider.dart';
import '../../../leaderboard/presentation/widget/home/leaderboard_home_widget.dart';
import '../../../../core/config/extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final _firebaseHelper = FirebaseHelper();
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  @override
  void initState() {
    if (gShowPopUpNews) {
      Future.delayed(gDelayedNavigation, () async {
        await _onRefresh(context, _authProvider.userData, true);

        gShowPopUpNews = false;
      });
    }

    super.initState();
  }

  @override
  void setState(VoidCallback fn) => (mounted) ? super.setState(fn) : fn();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: _authProvider.userModel,
      builder: (context, userData, promoWidget) {
        return CustomScrollView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildSliverAppBar(context),
            // if (!context.isMobile)
            CupertinoSliverRefreshControl(
              onRefresh: () async => await _onRefresh(context, userData, true),
            ),
            _buildCarousal(context),
            // TODO: Impian Kuliah Hanya Muncul Pada Siswa tingkat SMA
            if (!userData.isLogin ||
                userData.isKelasSMA ||
                userData.isKelasAlumni)
              _buildImpianKuliah(context),
            _buildJuaraBukuSakti(context, userData),
            SliverPadding(
              padding: EdgeInsets.symmetric(vertical: min(28, context.dp(20))),
              sliver: SliverToBoxAdapter(
                child: BookmarkHomeWidget(
                  isSiswa: userData.isSiswa,
                  noRegistrasi: userData?.noRegistrasi,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                  left: (context.isMobile) ? context.dp(24) : context.dp(18),
                  right: (context.isMobile) ? context.dp(24) : context.dp(18),
                  bottom: min(28, context.dp(20))),
              sliver: SliverToBoxAdapter(
                child: ValueListenableBuilder(
                  valueListenable:
                      context.read<AuthOtpProvider>().idSekolahKelas,
                  builder: (context, idSekolahKelas, child) =>
                      TeaserVideoHomeWidget(
                    isLogin: userData.isLogin,
                    isBeliVideoTeori:
                        context.read<AuthOtpProvider>().isProdukDibeliSiswa(88),
                    userType: userData?.siapa ?? 'No User',
                    idSekolahKelas:
                        userData?.idSekolahKelas ?? idSekolahKelas ?? '14',
                  ),
                ),
              ),
            ),
            promoWidget!,
            SliverToBoxAdapter(
              child: GoNewsHomeWidget(userData: userData),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                  height:
                      (context.isMobile) ? context.dp(136) : context.h(120)),
            ),
          ],
        );
      },
      child: SliverPadding(
        padding: EdgeInsets.only(
          left: (context.isMobile) ? context.dp(24) : context.dp(18),
          right: (context.isMobile) ? context.dp(24) : context.dp(18),
          bottom: min(32, context.dp(20)),
        ),
        sliver: const SliverToBoxAdapter(child: PromoHomeWidget()),
      ),
    );
  }

  Future<void> _onRefresh(
    BuildContext context,
    UserModel? userData, [
    bool isRefresh = true,
  ]) async {
    final BeritaProvider beritaProvider = context.read<BeritaProvider>();
    final PembayaranProvider pembayaranProvider =
        context.read<PembayaranProvider>();
    final KehadiranProvider kehadiranProvider =
        context.read<KehadiranProvider>();
    final CapaianProvider capaianProvider = context.read<CapaianProvider>();
    final LeaderboardProvider leaderboardProvider =
        context.read<LeaderboardProvider>();

    // _firebaseHelper.getAllJawabanSiswaRealTime();
    beritaProvider.loadBerita(
      isRefresh: isRefresh,
      userType: userData?.siapa ?? 'UMUM',
    );
    beritaProvider.loadBeritaPopUp(
      userType: userData?.siapa ?? 'UMUM',
    );

    if (isRefresh) {
      _authProvider.refreshUserData();
    }

    if (userData.isLogin) {
      pembayaranProvider.loadPembayaran(
        isRefresh: isRefresh,
        noRegistrasi: userData!.noRegistrasi,
      );
      pembayaranProvider.loadDetailPembayaran(
        isRefresh: isRefresh,
        noRegistrasi: userData.noRegistrasi,
      );
      kehadiranProvider.getKehadiranMingguIni(
        isRefresh: isRefresh,
        noRegistrasi: userData.noRegistrasi,
      );
    }

    // Jika login, ambil data pengerjaan soal siswa
    if (userData.isLogin) {
      capaianProvider.getCapaianScoreKamu(
        refresh: isRefresh,
        noRegistrasi: userData!.noRegistrasi,
        idSekolahKelas: userData.idSekolahKelas,
        tahunAjaran: _authProvider.tahunAjaran,
        userType: userData.siapa,
        idKota: userData.idKota,
        idGedung: userData.idGedung,
      );

      capaianProvider.getHasilPengerjaanSoal(
        refresh: isRefresh,
        isTamu: !userData.isLogin || userData.isTamu,
        noRegistrasi: userData.noRegistrasi,
        idSekolahKelas: userData.idSekolahKelas,
        tahunAjaran: _authProvider.tahunAjaran,
      );
    }

    leaderboardProvider.getFirstRankBukuSakti(
        idSekolahKelas: userData?.idSekolahKelas ??
            _authProvider.idSekolahKelas.value ??
            '14',
        idKota: userData?.idKota ?? '1',
        idGedung: userData?.idGedung ?? '2',
        tahunAjaran: _authProvider.tahunAjaran);
    _showBeritaPopUp();
  }

  /// NOTE: Tempat menyimpan widget method pada class ini------------------------
  // Build Sliver App Bar
  Widget _buildSliverAppBar(BuildContext context) {
    if (context.isMobile) {
      return ValueListenableBuilder<UserModel?>(
        valueListenable: _authProvider.userModel,
        builder: (context, userData, _) => SliverAppBar(
          elevation: 4,
          forceElevated: true,
          stretch: false,
          toolbarHeight: (userData.isTamu) ? context.dp(110) : context.dp(158),
          expandedHeight: (userData.isTamu) ? context.dp(110) : context.dp(158),
          backgroundColor: context.background,
          foregroundColor: context.background,
          surfaceTintColor: context.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: UserInfoAppBar(userData: userData),
          ),
        ),
      );
    }

    return const SliverAppBar(
      backgroundColor: Colors.transparent,
      toolbarHeight: 24,
    );
  }

  // Build Carousal Slider
  SliverPadding _buildCarousal(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: min(28, context.dp(20))),
      sliver: const SliverToBoxAdapter(
        child: CarouselWidget(),
      ),
    );
  }

  // Build Impian Kuliah
  SliverPadding _buildImpianKuliah(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        right: (context.isMobile) ? context.dp(24) : context.dp(18),
        left: (context.isMobile) ? context.dp(24) : context.dp(18),
        bottom: min(28, context.dp(20)),
      ),
      sliver: const SliverToBoxAdapter(child: ImpianKuliahWidget()),
    );
  }

  // Build Juara Buku Sakti
  SliverPadding _buildJuaraBukuSakti(
    BuildContext context,
    UserModel? userData,
  ) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: context.dp(12)),
      sliver: SliverToBoxAdapter(
        child: ValueListenableBuilder<String?>(
          valueListenable: _authProvider.idSekolahKelas,
          builder: (_, idSekolahKelas, __) => JuaraBukuSaktiWidget(
            isLogin: userData.isLogin,
            isNotTamu: !userData.isTamu,
            userData: userData,
            idSekolahKelas: idSekolahKelas,
            tahunAjaran: _authProvider.tahunAjaran,
          ),
        ),
      ),
    );
  }

  Future<void> _showBeritaPopUp() async {
    const duration = Duration(seconds: 1);

    await Future.delayed(duration).then(
      (value) {
        BuildContext context = gNavigatorKey.currentContext!;
        final popUpNews = context.read<BeritaProvider>().popUpNews[0];

        gShowBottomDialogInfo(
          context,
          displayIcon: false,
          dialogType: DialogType.info,
          title: popUpNews.title,
          message: '',
          content: SingleChildScrollView(
            child: Column(
              children: [
                if (popUpNews.image.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomImageNetwork.rounded(
                      popUpNews.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                Text(
                  "\n${popUpNews.summary}",
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          actions: (controller) => [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  gNavigatorKey.currentContext!,
                  Constant.kRouteDetailGoNews,
                  arguments: {
                    'berita':
                        Provider.of<BeritaProvider>(context, listen: false)
                            .popUpNews[0]
                  },
                );
                controller.dismiss(true);
              },
              child: const Text('Lihat detail'),
            ),
          ],
        );
      },
    );
  }
}
