import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../provider/video_provider.dart';
import '../widget/video_player_card.dart';
import '../../entity/video.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/platform_channel.dart';
import '../../../../core/shared/provider/log_provider.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/screen/custom_will_pop_scope.dart';
import '../../../../core/shared/widget/appbar/custom_app_bar.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Video video;
  final List<Video> daftarVideo;
  final String kodeBab;
  final String namaBab;
  final String namaMataPelajaran;

  const VideoPlayerScreen({
    Key? key,
    required this.video,
    required this.kodeBab,
    required this.namaBab,
    required this.namaMataPelajaran,
    required this.daftarVideo,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final ScrollController _scrollController = ScrollController();
  late Video _videoAktif = widget.video;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1300)).then(
        (value) => PlatformChannel.setSecureScreen(Constant.kRouteVideoPlayer));
    super.initState();
  }

  @override
  void dispose() {
    PlatformChannel.setSecureScreen('POP', true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlatformChannel.setSecureScreen(Constant.kRouteVideoPlayer);

    return Scaffold(
      backgroundColor: context.primaryColor,
      appBar: (context.isMobile)
          ? CustomAppBar(
              context,
              backgroundColor: context.primaryColor,
              jenisProduk: "Video",
              keterangan:
                  "${widget.namaMataPelajaran}, ${widget.video.judulVideo}",
              title: _buildTitle(context),
            )
          : null,
      body: CustomWillPopScope(
        onWillPop: () async {
          _saveLog();
          return Future<bool>.value(true);
        },
        onDragRight: () async {
          _saveLog();
          Navigator.pop(context);
        },
        child: ResponsiveBuilder(
          mobile: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoPlayerSection(context),
              _buildDetailDanRekomendasi(context),
            ],
          ),
          tablet: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _buildBackButtonTablet(context),
                          Expanded(child: _buildTitle(context)),
                        ],
                      ),
                      _buildVideoPlayerSection(context),
                    ],
                  ),
                ),
                _buildDetailDanRekomendasi(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconButton _buildBackButtonTablet(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.only(
        left: context.dp(6),
        right: context.dp(3),
      ),
      color: context.onPrimary,
      onPressed: () {
        context.read<LogProvider>().saveLog(
              userId: gNoRegistrasi,
              userType: "SISWA",
              menu: "Video",
              accessType: 'Keluar',
              info: "${widget.namaMataPelajaran}, ${widget.video.judulVideo}",
            );
        context.read<LogProvider>().sendLogActivity("SISWA");
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
    );
  }

  Column _buildTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${widget.kodeBab} ${widget.namaBab}",
          style: context.text.titleMedium?.copyWith(color: context.onPrimary),
          maxLines: (context.isMobile) ? 1 : 2,
          overflow: TextOverflow.fade,
        ),
        Text(
          widget.namaMataPelajaran,
          style: context.text.labelSmall?.copyWith(color: context.onPrimary),
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
      ],
    );
  }

  Widget _buildDetailDanRekomendasi(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaleFactor: context.textScale12),
      child: Expanded(
        flex: (context.isMobile) ? 1 : 3,
        child: Container(
          width: context.dw,
          margin:
              (context.isMobile) ? EdgeInsets.only(top: context.dp(12)) : null,
          padding: EdgeInsets.only(
            top: min(22, context.dp(18)),
            left: min(24, context.dp(20)),
            right: min(24, context.dp(20)),
          ),
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _videoAktif.judulVideo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium,
              ),
              const Divider(endIndent: 24, height: 18),
              Text(
                _videoAktif.deskripsi,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(
                  color: context.onBackground.withOpacity(0.8),
                ),
              ),
              const Divider(height: 18),
              if (widget.daftarVideo.length > 1) _buildDaftarVideo(context)
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildVideoPlayerSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: min(28, context.dp(24)),
        vertical: min(24, context.dp(20)),
      ),
      child: Selector<VideoProvider, String>(
        selector: (_, video) => video.streamToken,
        builder: (context, streamToken, loadingWidget) =>
            _buildVideoPlayerCard(loadingWidget, streamToken),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ShimmerWidget.rounded(
              width: double.infinity,
              height: double.infinity,
              borderRadius: gDefaultShimmerBorderRadius),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerCard(
    Widget? loadingWidget,
    String streamToken,
  ) {
    return Builder(
      builder: (context) {
        var videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(_videoAktif.linkVideo),
          formatHint: VideoFormat.other,
          httpHeaders: {
            'secretkey': streamToken,
            'credentialauth': Constant.kVideoCredential,
          },
        );

        return VideoPlayerCard(
          key: ValueKey(
              'VideoCard-${_videoAktif.idVideo}-${_videoAktif.judulVideo}'),
          video: _videoAktif,
          accessFrom: AccessVideoCardFrom.videoPlayerScreen,
          videoPlayerController: videoPlayerController,
          loadingWidget: loadingWidget!,
        );
      },
    );
  }

  Future<void> _saveLog() async {
    await gNavigatorKey.currentContext!.read<LogProvider>().saveLog(
          userId: gNoRegistrasi,
          userType: "SISWA",
          menu: "Video",
          accessType: 'Keluar',
          info: "${widget.namaMataPelajaran}, ${widget.video.judulVideo}",
        );
    // ignore: use_build_context_synchronously
    await gNavigatorKey.currentContext!
        .read<LogProvider>()
        .sendLogActivity("SISWA");
  }

  Expanded _buildDaftarVideo(BuildContext context) => Expanded(
        child: Scrollbar(
          controller: _scrollController,
          thickness: 8,
          radius: const Radius.circular(14),
          child: ListView.separated(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: min(18, context.dp(14)),
              bottom: min(34, context.dp(30)),
            ),
            separatorBuilder: (_, index) => const Divider(),
            itemCount: widget.daftarVideo.length,
            itemBuilder: (context, index) => _buildVideoItem(
              context,
              widget.daftarVideo[index],
              widget.daftarVideo[index].idVideo == _videoAktif.idVideo,
            ),
          ),
        ),
      );

  Widget _buildVideoItem(BuildContext context, Video video, bool isAktif) {
    var listTile = ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: (isAktif) ? null : () => setState(() => _videoAktif = video),
      leading: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          alignment: Alignment.bottomRight,
          decoration: BoxDecoration(
            color: context.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: AssetImage('assets/img/logo.webp'),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: context.disableColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.only(
              right: 4,
              bottom: 2,
              top: 6,
              left: 6,
            ),
            child: Text('11:00',
                style: context.text.labelSmall
                    ?.copyWith(color: context.onPrimary)),
          ),
        ),
      ),
      title: Text(
        video.judulVideo,
        maxLines: 2,
        style: context.text.titleSmall,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: min(5, context.dp(4))),
        child: Text(
          video.deskripsi,
          style: context.text.bodySmall?.copyWith(
            color: context.hintColor,
            fontSize: 10,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    return AnimatedContainer(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 300),
      padding: (isAktif)
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: (isAktif) ? Colors.black12 : context.background,
        borderRadius: (isAktif) ? gDefaultShimmerBorderRadius : null,
      ),
      child: listTile,
    );
  }
}
