import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../provider/video_provider.dart';
import '../../../model/video_jadwal.dart';
import '../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/screen/basic_screen.dart';
import '../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../core/shared/widget/expanded/custom_expansion_tile.dart';
import '../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class BabVideoJadwalScreen extends StatefulWidget {
  final String idMataPelajaran;
  final String namaMataPelajaran;
  final String? tingkatSekolah;
  final bool isRencanaPicker;

  const BabVideoJadwalScreen({
    Key? key,
    required this.idMataPelajaran,
    required this.namaMataPelajaran,
    this.tingkatSekolah,
    required this.isRencanaPicker,
  }) : super(key: key);

  @override
  State<BabVideoJadwalScreen> createState() => _BabVideoJadwalScreenState();
}

class _BabVideoJadwalScreenState extends State<BabVideoJadwalScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late final VideoProvider _videoProvider = context.read<VideoProvider>();
  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();
  late bool isBeliVideoEkstra =
      _authOtpProvider.isProdukDibeliSiswa(57, ortuBolehAkses: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget selectorVideoBab =
        Selector<VideoProvider, List<BabUtamaVideoJadwal>>(
      selector: (_, video) => video.getVideoJadwalByIdMapel(
          '${widget.idMataPelajaran}-${widget.tingkatSekolah ?? '-'}'),
      shouldRebuild: (previous, next) => next.any(
        (bab) {
          bool shouldRebuild = next.length != previous.length;

          if (!shouldRebuild &&
              previous.any((prev) => prev.namaBabUtama == bab.namaBabUtama)) {
            var prevBab = previous
                .where((prev) => prev.namaBabUtama == bab.namaBabUtama)
                .first;

            shouldRebuild =
                bab.daftarVideo.length != prevBab.daftarVideo.length ||
                    bab.daftarVideo.any(
                      (subBab) {
                        if (prevBab.daftarVideo.any((prevSubBab) =>
                            subBab.kodeBab == prevSubBab.kodeBab &&
                            subBab.idVideo == prevSubBab.idVideo)) {
                          var temp = prevBab.daftarVideo
                              .where((prevSubBab) =>
                                  subBab.kodeBab == prevSubBab.kodeBab &&
                                  subBab.idVideo == prevSubBab.idVideo)
                              .first;

                          return subBab.linkVideo != temp.linkVideo ||
                              subBab.judulVideo != temp.judulVideo ||
                              subBab.deskripsi != temp.deskripsi ||
                              subBab.keywords != temp.keywords ||
                              subBab.namaBab != temp.namaBab;
                        }
                        return false;
                      },
                    );
          }

          return shouldRebuild;
        },
      ),
      builder: (_, listVideoJadwal, emptyWidget) => FutureBuilder<void>(
          future: _onRefreshVideoJadwal(false),
          builder: (context, snapshot) {
            final bool isLoadingVideoJadwal =
                snapshot.connectionState == ConnectionState.waiting ||
                    context.select<VideoProvider, bool>(
                        (video) => video.isLoadingVideoJadwal);

            if (isLoadingVideoJadwal) {
              return const ShimmerListTiles(isWatermarked: true);
            }

            bool validateIsBeli = widget.idMataPelajaran != 'extra';

            if (kDebugMode) {
              logger.log(
                  'VIDEO_JADWAL_BAB_SCREEN: idMataPelajaran >> ${widget.idMataPelajaran}');
              logger.log(
                  'VIDEO_JADWAL_BAB_SCREEN: isBeliVideoEkstra >> $isBeliVideoEkstra');
              logger.log(
                  'VIDEO_JADWAL_BAB_SCREEN: validateIsBeli >> $validateIsBeli');
              logger.log(
                  'VIDEO_JADWAL_BAB_SCREEN: listVideoJadwal Is Empty >> ${listVideoJadwal.isEmpty}');
            }

            var refreshWidget = CustomSmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefreshVideoJadwal,
              isDark: true,
              child: (listVideoJadwal.isEmpty || !validateIsBeli)
                  ? emptyWidget!
                  : _buildListVideoJadwal(listVideoJadwal),
            );

            return (listVideoJadwal.isEmpty)
                ? refreshWidget
                : WatermarkWidget(child: refreshWidget);
          }),
      child: NoDataFoundWidget(
          subTitle:
              'Tidak ada Bab pada ${widget.namaMataPelajaran} (${widget.tingkatSekolah})',
          emptyMessage:
              'Belum ada Bab pada mata pelajaran ${widget.namaMataPelajaran} '
              '(${widget.tingkatSekolah}) yang sesuai dengan BAH.'),
    );

    return (widget.idMataPelajaran != 'extra')
        ? BasicScreen(
            title: widget.namaMataPelajaran,
            jumlahBarisTitle: 1,
            body: selectorVideoBab,
          )
        : Selector<VideoProvider, List<BabUtamaVideoJadwal>>(
            selector: (_, video) => video.getVideoJadwalByIdMapel(
                '${widget.idMataPelajaran}-${widget.tingkatSekolah ?? '-'}'),
            shouldRebuild: (previous, next) => next.any((bab) {
              bool shouldRebuild = next.length != previous.length;

              if (!shouldRebuild &&
                  previous
                      .any((prev) => prev.namaBabUtama == bab.namaBabUtama)) {
                var prevBab = previous
                    .where((prev) => prev.namaBabUtama == bab.namaBabUtama)
                    .first;

                shouldRebuild =
                    bab.daftarVideo.length != prevBab.daftarVideo.length ||
                        bab.daftarVideo.any(
                          (subBab) {
                            if (prevBab.daftarVideo.any((prevSubBab) =>
                                subBab.kodeBab == prevSubBab.kodeBab &&
                                subBab.idVideo == prevSubBab.idVideo)) {
                              var temp = prevBab.daftarVideo
                                  .where((prevSubBab) =>
                                      subBab.kodeBab == prevSubBab.kodeBab &&
                                      subBab.idVideo == prevSubBab.idVideo)
                                  .first;

                              return subBab.linkVideo != temp.linkVideo ||
                                  subBab.judulVideo != temp.judulVideo ||
                                  subBab.deskripsi != temp.deskripsi ||
                                  subBab.keywords != temp.keywords ||
                                  subBab.namaBab != temp.namaBab;
                            }
                            return false;
                          },
                        );
              }

              return shouldRebuild;
            }),
            builder: (_, listVideoJadwal, emptyWidget) => FutureBuilder<void>(
                future: _onRefreshVideoJadwal(false),
                builder: (context, snapshot) {
                  final bool isLoadingVideoJadwal =
                      snapshot.connectionState == ConnectionState.waiting ||
                          context.select<VideoProvider, bool>(
                              (video) => video.isLoadingVideoJadwal);

                  if (isLoadingVideoJadwal) {
                    return const ShimmerListTiles(isWatermarked: true);
                  }

                  var refreshWidget = CustomSmartRefresher(
                    controller: _refreshController,
                    onRefresh: _onRefreshVideoJadwal,
                    isDark: true,
                    child: (listVideoJadwal.isEmpty || !isBeliVideoEkstra
                        // dinonaktifkan sementara karena id produknya belum ada yang membeli
                        )
                        ? emptyWidget!
                        : _buildListVideoJadwal(listVideoJadwal),
                  );

                  return (listVideoJadwal.isEmpty)
                      ? refreshWidget
                      : Container(child: refreshWidget);
                }),
            child: NoDataFoundWidget(
                subTitle: (isBeliVideoEkstra)
                    ? 'Video ${widget.namaMataPelajaran} belum tersedia'
                    : 'Sobat Belum membeli produk video ekstra',
                emptyMessage: (isBeliVideoEkstra)
                    ? 'Belum ada Video ${widget.namaMataPelajaran} yang tersedia saat ini.'
                    : 'Silahkan beli produk video ekstra terlebih dahulu ya Sobat'),
          );
  }

  Future<void> _onRefreshVideoJadwal([bool refresh = true]) async {
    // Function load and refresh data
    await _videoProvider
        .getVideoJadwal(
            isRefresh: refresh,
            noRegistrasi: _authOtpProvider.userData?.noRegistrasi ??
                _authOtpProvider.nomorHp,
            idMataPelajaran: widget.idMataPelajaran,
            tingkatSekolah: widget.tingkatSekolah ?? "-")
        .then((_) => _refreshController.refreshCompleted());

    if (refresh) {
      _refreshController.refreshCompleted();
    }
  }

  void _navigateToVideoPlayerScreen({
    required String namaBabUtama,
    required VideoJadwal videoAktif,
    required List<VideoJadwal> daftarVideo,
  }) {
    Map<String, dynamic> argument = {
      'video': videoAktif,
      'daftarVideo': daftarVideo,
      'kodeBab': videoAktif.kodeBab,
      'namaBab': videoAktif.namaBab,
      'namaMataPelajaran': widget.namaMataPelajaran,
    };

    if (widget.isRencanaPicker) {
      argument.putIfAbsent('idJenisProduk', () => 88);
      argument.putIfAbsent(
        'keterangan',
        () => 'Menonton Video ${widget.namaMataPelajaran} '
            'Bagian Bab ${videoAktif.kodeBab} - ${videoAktif.judulVideo}.',
      );

      // Kirim data ke Rencana Belajar Editor
      Navigator.pop(context, argument);
      if (widget.idMataPelajaran != 'extra') {
        Navigator.pop(context, argument);
      }
    } else {
      Navigator.pushNamed(
        context,
        Constant.kRouteVideoPlayer,
        arguments: argument,
      );
    }
  }

  Widget _buildListVideoJadwal(List<BabUtamaVideoJadwal> listBab) =>
      ListView.separated(
        itemCount: listBab.length,
        padding: EdgeInsets.only(top: context.dp(8), bottom: context.dp(30)),
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, index) => CustomExpansionTile(
          title: Text(
            listBab[index].namaBabUtama,
            style: context.text.titleSmall?.copyWith(
              fontFamily: 'Montserrat',
            ),
          ),
          subtitle: Text(
            'Jumlah Video: ${listBab[index].daftarVideo.length}',
            style: context.text.bodySmall?.copyWith(color: Colors.black54),
          ),
          children: listBab[index]
              .daftarVideo
              .map<Widget>(
                (video) => _buildItemBab(
                  videoAktif: video,
                  daftarVideo: listBab[index].daftarVideo,
                  namaBabUtama: listBab[index].namaBabUtama,
                ),
              )
              .toList(),
        ),
      );

  Widget _buildItemBab({
    required String namaBabUtama,
    required VideoJadwal videoAktif,
    required List<VideoJadwal> daftarVideo,
  }) {
    return Container(
      constraints: BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
        minHeight: min(54, context.dp(38)),
        // maxHeight: context.dp(60),
      ),
      margin: EdgeInsets.only(left: context.dp(24)),
      padding: EdgeInsets.only(
        top: min(12, context.dp(8)),
        right: min(32, context.dp(24)),
        bottom: min(12, context.dp(8)),
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.disableColor)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        onTap: () => _navigateToVideoPlayerScreen(
          videoAktif: videoAktif,
          namaBabUtama: namaBabUtama,
          daftarVideo: daftarVideo,
        ),
        minLeadingWidth: min(46, context.dp(32)),
        leading: Icon(
          Icons.movie_outlined,
          color: context.tertiaryColor,
          size: min(46, context.dp(32)),
        ),
        title: Text(
          videoAktif.judulVideo,
          textAlign: TextAlign.left,
          semanticsLabel: 'Bab dan Sub Bab Kisi-Kisi',
        ),
        subtitle: RichText(
          textAlign: TextAlign.left,
          textScaleFactor: context.textScale12,
          text: TextSpan(
            text: '(${videoAktif.kodeBab}) ~ ',
            style: context.text.labelSmall?.copyWith(color: Colors.black54),
            semanticsLabel: 'Bab ${videoAktif.kodeBab}',
            children: [
              TextSpan(
                text: videoAktif.namaBab,
                style: context.text.bodySmall?.copyWith(color: Colors.black54),
                semanticsLabel: 'Bab ${videoAktif.namaBab}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
