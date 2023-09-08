import 'dart:developer' as logger show log;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/shared/widget/empty/no_data_found.dart';
import '../provider/video_provider.dart';
import '../../entity/video.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';

enum AccessVideoCardFrom { videoPlayerScreen, videoSolusi }

class VideoPlayerCard extends StatefulWidget {
  final Video video;
  final EdgeInsetsGeometry? padding;
  final VideoPlayerController videoPlayerController;
  final AccessVideoCardFrom accessFrom;
  final bool allowFullScreen;
  final Widget loadingWidget;

  const VideoPlayerCard({
    Key? key,
    required this.video,
    required this.videoPlayerController,
    this.padding,
    required this.accessFrom,
    this.allowFullScreen = true,
    required this.loadingWidget,
  }) : super(key: key);

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  bool _playerVisible = true;
  late final ChewieController _chewieController = ChewieController(
    videoPlayerController: widget.videoPlayerController,
    aspectRatio: 16 / 9,
    autoPlay: true,
    showControls: true,
    autoInitialize: true,
    allowFullScreen: widget.allowFullScreen,
    deviceOrientationsOnEnterFullScreen: [
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ],
    deviceOrientationsAfterFullScreen: [
      DeviceOrientation.portraitUp,
    ],
    placeholder: ShimmerWidget.rounded(
        width: double.infinity,
        height: double.infinity,
        borderRadius: gDefaultShimmerBorderRadius),
    errorBuilder: (_, errorMessage) {
      if (kDebugMode) {
        logger.log('VIDEO_TEASER_WIDGET-ErrorChewie: $errorMessage');
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            'Oops, gagal menyiapkan video. Coba lagi!',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium,
          ),
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(gDelayedNavigation)
        .then((value) => _chewieController.addListener(_exitFullscreen));
  }

  @override
  void dispose() {
    super.dispose();
    Future.delayed(gDelayedNavigation).then((_) {
      _chewieController.removeListener(_exitFullscreen);
      _chewieController.dispose();
      widget.videoPlayerController.dispose();
      logger
          .log('VIDEO_PLAYER_CARD: Dispose called ${widget.video.judulVideo}');
    });
  }

  void _exitFullscreen() {
    if (kDebugMode) {
      logger.log('VIDEO_PLAYER_CARD-Listener: Exit Full Screen called\n'
          'Is Full Screen >> ${_chewieController.isFullScreen}\n'
          'Player Visible >> $_playerVisible');
    }
    if (!_playerVisible && !_chewieController.isFullScreen) {
      _playerVisible = true;
      String routeName = Constant.kRouteVideoPlayer;

      switch (widget.accessFrom) {
        case AccessVideoCardFrom.videoSolusi:
          routeName = Constant.kRouteVideoSolusi;
          break;
        default:
          break;
      }

      Navigator.popUntil(
          gNavigatorKey.currentState!.context, ModalRoute.withName(routeName));

      if (context.isMobile) {
        Future.delayed(gDelayedNavigation, () => gSetDeviceOrientations());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<VideoProvider, String>(
      selector: (_, video) => video.streamToken,
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, streamToken, child) => FutureBuilder<String>(
        future: context.read<VideoProvider>().getTokenStream(),
        builder: (context, snapshot) {
          bool isLoading = snapshot.connectionState == ConnectionState.waiting;
          if (isLoading) {
            return widget.loadingWidget;
          }

          if (snapshot.hasError) {
            return NoDataFoundWidget(
              shrink: true,
              isLandscape: !context.isMobile,
              textColor: context.onBackground,
              imageUrl: 'ilustrasi_server_error.png'.illustration,
              subTitle: 'Terjadi kesalahan saat menyiapkan '
                  'Video ${widget.video.judulVideo}. Coba lagi!',
              emptyMessage: snapshot.error.toString(),
            );
          }

          return Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: gDefaultShimmerBorderRadius,
            ),
            child: ClipRRect(
              borderRadius: gDefaultShimmerBorderRadius,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: VisibilityDetector(
                  key: ValueKey(
                      '${widget.video.idVideo}-${widget.video.judulVideo}'),
                  onVisibilityChanged: (info) {
                    _playerVisible = info.visibleFraction != 0;
                    if (info.visibleFraction == 0) {
                      widget.videoPlayerController.pause();
                      _chewieController.pause();
                    }
                  },
                  child: Chewie(
                    controller: _chewieController,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
