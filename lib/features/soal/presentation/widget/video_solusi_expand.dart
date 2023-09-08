import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../video/model/video_soal.dart';
import '../../../video/presentation/provider/video_provider.dart';
import '../../../video/presentation/widget/video_player_card.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/animation/custom_rect_tween.dart';

class VideoSolusiExpand extends StatelessWidget {
  final VideoSoal videoSolusi;

  const VideoSolusiExpand({
    Key? key,
    required this.videoSolusi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(min(28, context.dp(24))),
        child: Hero(
          tag: 'video_solusi',
          transitionOnUserGestures: true,
          createRectTween: (begin, end) =>
              CustomRectTween(begin: begin, end: end),
          child: Material(
            elevation: 4,
            color: Colors.transparent,
            borderRadius: gDefaultShimmerBorderRadius,
            child: SingleChildScrollView(
              child: Selector<VideoProvider, String>(
                selector: (_, video) => video.streamToken,
                builder: (context, streamToken, _) => VideoPlayerCard(
                  video: videoSolusi,
                  accessFrom: AccessVideoCardFrom.videoSolusi,
                  allowFullScreen: true,
                  padding: const EdgeInsets.all(6),
                  videoPlayerController: VideoPlayerController.networkUrl(
                    Uri.parse(videoSolusi.linkVideo),
                    formatHint: VideoFormat.other,
                    httpHeaders: {
                      'secretkey': streamToken,
                      'credentialauth': Constant.kVideoCredential,
                    },
                  ),
                  loadingWidget: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ShimmerWidget.rounded(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: gDefaultShimmerBorderRadius),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
