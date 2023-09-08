import 'package:flutter/material.dart';

import '../../model/video_teori.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';

class DaftarVideoTeori extends StatelessWidget {
  final String namaBabSubBab;
  final bool isBeliVideoTeori;
  final List<VideoTeori> daftarVideo;
  final Function(VideoTeori) onClickVideo;

  const DaftarVideoTeori({
    super.key,
    required this.isBeliVideoTeori,
    required this.namaBabSubBab,
    required this.daftarVideo,
    required this.onClickVideo,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final headerWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: (!isBeliVideoTeori)
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.video_library_outlined,
          color: context.primaryColor,
          size: context.dp(32),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            textScaleFactor: context.textScale12,
            text: TextSpan(
                text: 'e-Video Teori\n',
                style: context.text.titleMedium,
                children: [
                  TextSpan(
                      text: (!isBeliVideoTeori)
                          ? 'Yaah, Kamu belum membeli produk Video Teori Sobat. '
                              'e-Video Teori merupakan fitur untuk kamu yang lebih suka belajar '
                              'menggunakan format video daripada text.'
                          : (daftarVideo.isEmpty)
                              ? 'Belum ada video terkait dengan teori bab $namaBabSubBab Sobat'
                              : '~Video terkait bab $namaBabSubBab',
                      style: context.text.labelMedium
                          ?.copyWith(color: context.hintColor))
                ]),
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        top: context.dp(24),
        bottom: context.dp(20),
        left: context.dp(18),
        right: context.dp(18),
      ),
      child: (daftarVideo.isEmpty || !isBeliVideoTeori)
          ? headerWidget
          : Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8,
              radius: const Radius.circular(14),
              child: ListView(
                shrinkWrap: true,
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  headerWidget,
                  SizedBox(height: context.dp(12)),
                  ...List<Widget>.generate(
                    daftarVideo.length,
                    (index) => _buildVideoButton(context,
                        video: daftarVideo[index], part: index + 1),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildVideoButton(
    BuildContext context, {
    required VideoTeori video,
    required int part,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.hintColor)),
      ),
      child: ListTile(
        dense: true,
        onTap: () => onClickVideo(video),
        shape:
            RoundedRectangleBorder(borderRadius: gDefaultShimmerBorderRadius),
        title: RichText(
          textScaleFactor: context.textScale12,
          text: TextSpan(
              text: '$namaBabSubBab ',
              style: context.text.bodyMedium,
              semanticsLabel: 'e-Video Teori ${video.idVideo} title',
              children: [
                TextSpan(
                  text: 'Part ($part)',
                  style: context.text.bodySmall?.copyWith(
                    color: context.hintColor,
                  ),
                  semanticsLabel: 'e-Video Teori ${video.idVideo} subtitle',
                )
              ]),
          maxLines: 2,
          textAlign: TextAlign.left,
        ),
        leading: const Icon(Icons.movie_outlined),
      ),
    );
  }
}
