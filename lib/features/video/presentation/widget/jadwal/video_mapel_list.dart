import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../provider/video_provider.dart';
import '../../../entity/video_mapel.dart';
import '../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [VideoMapelList] merupakan list Mapel sesuai BAH yang
/// mempunyai e-Video Teori atau e-Video Ekstra.<br><br>
///
/// Jenis Produk Video yang digunakan:<br>
/// 1) e-Video Ekstra (id: 57).<br>
/// 2) e-Video Teori (id: 88).<br>
class VideoMapelList extends StatefulWidget {
  final bool isRencanaPicker;

  const VideoMapelList({
    Key? key,
    this.isRencanaPicker = false,
  }) : super(key: key);

  @override
  State<VideoMapelList> createState() => _VideoMapelListState();
}

class _VideoMapelListState extends State<VideoMapelList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<VideoProvider, List<VideoMapel>>(
      selector: (_, video) => video.getVideoJadwalMapelFromCache(
          _authOtpProvider.userData?.noRegistrasi ?? _authOtpProvider.nomorHp,
          _authOtpProvider.userData?.siapa ?? _authOtpProvider.userType),
      shouldRebuild: (previous, next) => next.any((buku) {
        bool shouldRebuild = next.length != previous.length;

        if (!shouldRebuild &&
            previous
                .any((prev) => prev.idMataPelajaran == buku.idMataPelajaran)) {
          var prevBuku = previous
              .where((prev) => prev.idMataPelajaran == buku.idMataPelajaran)
              .first;

          shouldRebuild = buku.namaMataPelajaran != prevBuku.namaMataPelajaran;
        }

        return shouldRebuild;
      }),
      builder: (_, listMataPelajaran, loadingWidget) => FutureBuilder<void>(
          future: _onRefreshVideoMapel(false),
          builder: (context, snapshot) {
            final bool isLoadingVideoMapel =
                snapshot.connectionState == ConnectionState.waiting ||
                    context.select<VideoProvider, bool>(
                        (video) => video.isLoadingVideoJadwalMapel);

            if (isLoadingVideoMapel) {
              return loadingWidget!;
            }

            var refreshWidget = CustomSmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefreshVideoMapel,
                isDark: true,
                child: (listMataPelajaran.isEmpty)
                    ? _getIllustrationImage()
                    : _buildListMapel(listMataPelajaran)

                //_buildListMapel(listMataPelajaran),
                );

            return (listMataPelajaran.isEmpty)
                ? refreshWidget
                : WatermarkWidget(child: refreshWidget);
          }),
      child: const ShimmerListTiles(isWatermarked: true),
    );
  }

  bool _isProdukDibeli({bool ortuBolehAkses = false}) {
    bool isBeliVideoTeori = _authOtpProvider.isProdukDibeliSiswa(88,
        ortuBolehAkses: ortuBolehAkses);
    bool isBeliVideoEkstra = _authOtpProvider.isProdukDibeliSiswa(57,
        ortuBolehAkses: ortuBolehAkses);

    return isBeliVideoTeori || isBeliVideoEkstra;
  }

  // On Refresh Function
  Future<void> _onRefreshVideoMapel([bool refresh = true]) async {
    // Function load and refresh data
    await context
        .read<VideoProvider>()
        .getVideoJadwalMapel(
          isRefresh: refresh,
          isProdukDibeli: _isProdukDibeli(),
          noRegistrasi: _authOtpProvider.userData?.noRegistrasi ??
              _authOtpProvider.nomorHp,
          userType:
              _authOtpProvider.userData?.siapa ?? _authOtpProvider.userType,
        )
        .then((_) => _refreshController.refreshCompleted());
  }

  // Get Illustration Image Function
  Widget _getIllustrationImage() {
    Widget noDataFound = NoDataFoundWidget(
      shrink: (context.dh < 600) ? !context.isMobile : false,
      subTitle: gEmptyProductSubtitle(
          namaProduk: 'Video Teori BAH',
          isProdukDibeli: _isProdukDibeli(ortuBolehAkses: true),
          isOrtu: _authOtpProvider.isOrtu,
          isNotSiswa: !_authOtpProvider.isSiswa),
      emptyMessage: gEmptyProductText(
        namaProduk: 'Video Teori BAH',
        isOrtu: _authOtpProvider.isOrtu,
        isProdukDibeli: _isProdukDibeli(ortuBolehAkses: true),
      ),
    );

    return (context.isMobile || context.dh > 600)
        ? noDataFound
        : SingleChildScrollView(
            child: noDataFound,
          );
  }

  Widget _buildLeadingItem({required VideoMapel mataPelajaran}) {
    var leadingWidget = LayoutBuilder(
      builder: (context, constraints) => (mataPelajaran.imageUrl != null)
          ? CustomImageNetwork.rounded(
              mataPelajaran.imageUrl!,
              width: constraints.maxHeight,
              height: constraints.maxHeight,
              fit: BoxFit.fitHeight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            )
          : ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                'assets/img/default_buku.png',
                width: constraints.maxHeight,
                height: constraints.maxHeight,
                fit: BoxFit.fitHeight,
              ),
            ),
    );

    return leadingWidget;
  }

  // List Bundel Widgets
  Widget _buildListMapel(List<VideoMapel> listMapel) => ListView.separated(
        itemCount: listMapel.length,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: min(32, context.dp(20)),
          bottom: min(40, context.dp(30)),
          left: (context.isMobile) ? 0 : 18,
        ),
        separatorBuilder: (_, index) => Divider(
          indent: min(82, context.dp(64)),
        ),
        itemBuilder: (_, index) => ListTile(
          onTap: () => Navigator.pushNamed(
            context,
            Constant.kRouteVideoJadwalBab,
            arguments: {
              'idMataPelajaran': listMapel[index].idMataPelajaran,
              'namaMataPelajaran': listMapel[index].namaMataPelajaran,
              'tingkatSekolah': listMapel[index].tingkatSekolah,
              'isRencanaPicker': widget.isRencanaPicker
            },
          ),
          leading: _buildLeadingItem(mataPelajaran: listMapel[index]),
          title: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: context.textScale14,
            text: TextSpan(
              text: listMapel[index].namaMataPelajaran,
              style: context.text.titleMedium,
              children: [
                TextSpan(
                  text: '  (${listMapel[index].tingkatSekolah})',
                  style: context.text.bodySmall
                      ?.copyWith(fontSize: 10, color: context.hintColor),
                ),
              ],
            ),
          ),
          // subtitle: Text(
          //   '(${listMapel[index].tingkatSekolah})',
          //   style: context.text.bodySmall,
          // ),
        ),
      );
}
